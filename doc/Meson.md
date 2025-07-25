# Meson Build System
After using Make and CMake for nearly my whole career, I just wanted to try out another build system which might be a bit more comfortable than Make. [Meson](https://mesonbuild.com/) has a couple of interesting approaches and uses a Python-like syntax for the build files.

One major drawback (at least from my perspective) is the concept Meson uses for sub-projects. As far as I know, Meson expects sub-projects (like libraries etc.) in a sub-folder named `subprojects`. An this is for me an absolute no-go. I don't like it, if the build system is making constraints about my project structure. Anyway, Meson has really cool features and works really good so far for my project. Due to the reduced functionality with sub-directory builds, I've used just one Meson build file to include all libraries and software parts of StudyOS.

## Basic Settings
Inside the Meson build file, a couple of basic settings are defined. This includes for example necessary tools and default options for those tools. But also configuration settings about the folder structure is made in the beginning of the Meson build file

The following sections shows the common directory configuration for the build. This includes also the sub-projects with the different libraries.

```meson
###############################################################################
# Generic Setups
###############################################################################
lib_source_dir   = 'src/lib/'
lib_bios_dir = lib_source_dir + 'bios/'
lib_lowlevel_dir = lib_source_dir + 'lowlevel/'
lib_env_dir = lib_source_dir + 'env/'

lib_bios_inc = '../' + lib_bios_dir
lib_lowlevel_inc = '../' + lib_lowlevel_dir
lib_env_inc = '../' + lib_env_dir
```

The next section defines the tools used to build the necessary artifacts.

```meson
#
# Tools used for Generators and Custom-Targets
#
gas = find_program('as')            # GNU Assembler
ld = find_program('ld')             # GNU Natvie Linker
gcc = find_program('gcc')           # GNU C Compiler
dd = find_program('dd')             # dd Tool
objcopy = find_program('objcopy')   # objcopy Tool
bash = find_program('bash')         # Bash Shell
sudo = find_program('sudo')         # Sudo Tool
```
