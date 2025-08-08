#! @python3@/bin/python3 -B
# Refind Stanza Builder by Karui Hoshimiya~
# based on GrandtheUK (https://github.com/GrandtheUK/refind-nix) work.

import os
import os.path
import errno
import subprocess
import glob
import datetime

# globals
MAX_ENTRIES = 100
MENU_ENTRY = """
menuentry "NixOS" {{
    volume "{volume}"
    loader {kernel}
    initrd {initrd}
    options "{kernel_params}"
    {submenu_entries}
}}
"""
SUBMENU_ENTRY = """
submenuentry "Generation {generation} {description}" {{
    volume "{volume}"
    loader {kernel}
    initrd {initrd}
    options "{kernel_params}"
}}
"""
VOLUME= "@volume@"
NIX = "@nix@"
NIX_SUBVOLUME_PATH = "@nix_subvolume@"
REFIND_PATH = "@efiSysMountPoint@/EFI/refind"

# functions
def mkdir_p(path: str):  
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno != errno.EEXIST or not os.path.isdir(path):
            raise

def get_generations():
    gen_list = subprocess.check_output([
        "%s/bin/nix-env" % NIX,
        "--list-generations",
        "-p",
        "/nix/var/nix/profiles/system",
        "--option",
        "build-users-group",
        ""
    ], universal_newlines=True)
    gen_lines = gen_list.split('\n')
    gen_lines.pop() # remove empty newline  # pyright: ignore[reportUnusedCallResult]
    return [int(line.split()[0]) for line in gen_lines]

def describe_generation(generation_dir: str):
    try:
        with open("%s/nixos-version" % generation_dir) as version_file:
            nixos_version = version_file.read()
    except IOError:
        nixos_version = "Unknown"

    kernel_dir = os.path.dirname(os.path.realpath("%s/kernel" % generation_dir))
    module_dir = glob.glob("%s/lib/modules/*" % kernel_dir)[0]
    kernel_version = os.path.basename(module_dir)

    build_time = int(os.path.getctime(generation_dir))
    build_date = datetime.datetime.fromtimestamp(build_time).strftime('%F')

    return "NixOS {} (Linux {}), Built on {}".format(nixos_version, kernel_version, build_date)

def get_generation_info(generation: int):
    generation_dir = "/nix/var/nix/profiles/system-%d-link" % generation
    kernel = os.readlink("%s/kernel" % generation_dir).replace("/nix", NIX_SUBVOLUME_PATH, 1)
    initrd = os.readlink("%s/initrd" % generation_dir).replace("/nix", NIX_SUBVOLUME_PATH, 1)
    kernel_params = "systemConfig=%s init=%s/init " % (generation_dir, generation_dir)
    with open("%s/kernel-params" % generation_dir) as params_file:
        kernel_params += params_file.read()
    description = describe_generation(generation_dir)
    return {
        "generation": generation,
        "volume": VOLUME,
        "kernel": kernel,
        "initrd": initrd,
        "kernel_params": kernel_params,
        "description": description
    }

def write_refind_conf(path: str, default_generation: int, generations: list[int]):
    with open(path, 'w') as output:
        reverse_gens = sorted(generations, reverse=True)
        submenu_entries = []
        current_entry = 1
        for generation in reverse_gens:
            if current_entry > MAX_ENTRIES:
                break
            submenu_entries.append(SUBMENU_ENTRY.format(
                **get_generation_info(generation)
            ))
            current_entry+=1

        output.write(MENU_ENTRY.format(  # pyright: ignore[reportUnusedCallResult]
            **get_generation_info(default_generation),
            submenu_entries="\n".join(submenu_entries)
        ))

def main():
    mkdir_p(REFIND_PATH)
    generations = get_generations()
    default_generation = generations[-1] # latest generation is default
    write_refind_conf("%s/nixos_stanza.conf" % REFIND_PATH, default_generation, generations)

if __name__ == '__main__':
    main()
