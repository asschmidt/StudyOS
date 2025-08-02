# Meson Build System
After using Make and CMake for nearly my whole career, I just wanted to try out another build system which might be a bit more comfortable than Make. [Meson](https://mesonbuild.com/) has a couple of interesting approaches and uses a Python-like syntax for the build files.

One major drawback (at least from my perspective) is the concept Meson uses for sub-projects. As far as I know, Meson expects sub-projects (like libraries etc.) in a sub-folder named `subprojects`. An this is for me an absolute no-go. I don't like it, if the build system is making constraints about my project structure. Anyway, Meson has really cool features and works really good so far for my project. Due to the reduced functionality with sub-directory builds, I've used just one Meson build file to include all libraries and software parts of StudyOS.

## Basic Settings
Inside the Meson build file, a couple of basic settings are defined. This includes for example necessary tools and default options for those tools. But also configuration settings about the folder structure is made in the beginning of the Meson build file

The following section shows the common directory configuration for the build. This includes also the sub-projects with the different libraries.

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

The variables for the directories are later used to specify the source files for the different build targets and also for tool configuration parameter like include file directories.

The next section defines the tools used to build the necessary artifacts. This covers the classical tools like assembler, compiler and linker but also some command line tools for script execution and disk image setup.

```meson
#
# Tools used for Generators and Custom-Targets
#
gas = find_program('as')            # GNU Assembler
ld = find_program('ld')             # GNU Natvie Linker
gcc = find_program('gcc')           # GNU C Compiler
cpp = find_program('cpp')           # GNU C Preprocessor
dd = find_program('dd')             # dd Tool
objcopy = find_program('objcopy')   # objcopy Tool
bash = find_program('bash')         # Bash Shell
sudo = find_program('sudo')         # Sudo Tool
```

The advantage of specifying the necessary tools in this way is, that Meson will check for their existence during the generation of the Ninja build files.

In the next section, some common tool parameters like command line parameter for the GNU Assembler and GNU C Compiler are defined

```meson
###############################################################################
# Common Tool Settings
###############################################################################

# GNU Assembler
# Debug Infos -g
# Architecture i386
# 32 Bit (not 64 Bit by default)
# Using Intel Syntax
gas_args_32bit = ['-g', '-march=i386', '--32', '-msyntax=intel']

# GNU C Compiler
# Debug Infos -g
# 32 Bit (not 64 Bit by default)
gcc_args_32bit = ['-g', '-m32']

#
# GNU Pre-Processor Arguments for Assembler-Usage
cpp_args = ['-P', '-CC', '-nostdinc', '-traditional-cpp']
```
The parameter for the assembler are used for nearly all assembly processes during the build. As it can be seen, the settings cover the activation of Debug-Information, setting the target CPU architecture and specifying the default syntax.

For the GNU C Compiler, only the Debug-Information are activated and also the target architecture is set to 32 Bit.

## Library Targets
After all the common configuration settings, the first build target is specified. This is a static library for BIOS functions in Real-Mode.

```meson
###############################################################################
# Lib BIOS
###############################################################################
lib_bios_asm_gen = generator(gas,
    output: '@BASENAME@.o',
    arguments: [gas_args_32bit,
                '-I', lib_bios_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

lib_bios_asm_preproc = generator(cpp,
    output: '@BASENAME@.i',
    arguments: [cpp_args,
                '-I', lib_bios_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

# Setup the C-Source Files for the BIOS Lib
lib_bios_c_source_files = files(lib_bios_dir + 'bios_structs.c')

# Setup the ASM-Source Files for the LowLevel Lib
lib_bios_source_files = files(lib_bios_dir + 'bios_stdio.asm')
lib_bios_source_files += files(lib_bios_dir + 'bios_disk.asm')
lib_bios_source_files += files(lib_bios_dir + 'bios_memory.asm')

# Preprocess the ASM files
lib_bios_preproc_files = lib_bios_asm_preproc.process(lib_bios_source_files)

# Assemble the ASM source files to object files
lib_bios_object_files = lib_bios_asm_gen.process(lib_bios_preproc_files)

# Create the static library for liblowlevel
lib_bios = static_library('bios',
                    c_args: [gcc_args_32bit],
                    sources: lib_bios_c_source_files,
                    objects: lib_bios_object_files)
```

Due to the concept of Meson, there is no way to specfiy some rules how to "convert" a `.asm`file into an object file (like it is possible in Make). Instead, Meson uses the concept of _Generators_. A _Generator_ is a program, including parameters, to either generate specific files or, like in our case, to transform files from a specific input format into an output format.

In the code section shown above, a generator is defined to use the GNU Assembler as program with the defined command line parameters. Additionally, a generic concept of specifying input and output files is used. This is achieved by the pre-defined variables `@INPUT@`, `@OUTPUT@` and `@BASENAME@`.

After the generator definition, the source files (C- and Assembler-Source Files are defined). But before the static library can be built with the integrated Meson function `static_library()`, the assembler source files must be transformed into object files which can be added as input to the static library.

Finally, the static library is built with the specified C-Source-Files and the already assembled object files. This concept of creating static libraries is used for all libraries in the project. Beside the `libbios`, there are also `liblowlevel` and `libenv`.

## Main Build Targets
The first main build target in the Meson build file is the Stage 1 Bootloader. This build target is split into two separate parts. The first part is pretty similar to the static library and contains the generator definition for the assembly process and the definition of the source files

```meson
###############################################################################
# Stage1 Boootloader
###############################################################################
# Define the ASM Generator for Stage 1
stage1_asm_gen = generator(gas,
    output: '@BASENAME@.o',
    arguments: [gas_args_32bit,
                '-I', lib_lowlevel_inc,
                '-I', lib_bios_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

# Define the output filenames for Stage1 Raw Binary incl. a Map file
stage1_bin_output       = 'boot_stage1_bin'
stage1_bin_output_map   = stage1_bin_output + '.map'

# Define the output filenames for Stage1 ELF incl. a Map file
# This is used to provide debugging symbols for the debugger and the additional
# Map File can be used to cross check the binary/elf output of the Linker
stage1_elf_output      = 'boot_stage1_elf'
stage1_elf_output_map   = stage1_elf_output + '.map'

# Define the Bootloader Stage1 Sources
stage1_source_dir   = 'src/bootloader/stage1/'
stage1_source_files = files(stage1_source_dir + 'stage1.asm')


# Generate the Object Files for Stage1
stage1_object_files = stage1_asm_gen.process(stage1_source_files)
```
Additionally, a couple of output file names are defined. These file names are relevante for the linker configuration when building the binaries.

The next part of the build target for Stage 1 bootloader is the link process. This includes the linker configuration and the linking of the ELF binary. Additionally, a raw binary is created out of the ELF binary.

```meson
#
# Setup Linker related options
#

# Linker File to use for stage1
stage1_linker_file  = files(stage1_source_dir + 'stage1.ld')

# Linker arguments used for all targets
stage1_linker_args  = ['-Wl,-melf_i386', '-Wl,--gc-sections', '-g', '--function-sections', '--data-sections', '-nodefaultlibs', '-nostdlib', '-nostartfiles', '-nolibc', '-Os']
# Linker arguments used to gernerate the ELF
stage1_elf_linker_args  = stage1_linker_args + ['-Wl,--oformat=elf32-i386']

#
# Build Target to create the ELF for Stage1
#
stage1_link_elf     = executable(stage1_elf_output, stage1_object_files,
                        name_suffix: 'elf',
                        link_args : [stage1_elf_linker_args,
                                   '-Wl,-Map,' + stage1_elf_output_map,
                                   '-T', stage1_linker_file[0].full_path()
                                    ],
                        link_depends: stage1_linker_file,
                        link_whole: [lib_bios, lib_lowlevel])

#
# Generate a Floppy-Image (1,44 MB) incl. partitions
#
stage1_link_bin   = custom_target(stage1_bin_output,
                        input: [stage1_link_elf],
                        output: [stage1_bin_output + '.bin'],
                        command: [objcopy,
                                  '-O', 'binary',
                                  '--only-section=.text*',
                                  '--only-section=.data*',
                                  '--only-section=.rodata*',
                                  '--only-section=.fill*',
                                  '@INPUT@',
                                  '@OUTPUT0@'],
                        depends: [stage1_link_elf])
```

As usual, some linker options are defined. The different options will be described in the next section. After the definition of the command line options, the build targets are defined. At first, there is a `stage1_link_elf` target defined. This is based on the Meson function `executable()` and will generate an ELF binary based on the input object files and static libraries provided as inputs to the function. Additionally, a specific linker script and Map Output Filename is specified. So the Linker uses the configuration from the linker scripts and generates a map file for additional information about the resulting binary.

>[!NOTE]
>The ELF binary is created for two reasons:
> * It provides debugging information for GDB when we want to debug our bootloader on source level
> * If the Linker is used to generate directly a raw binary, the "Garbage Collection" of unused function sections is not working and therefore the resulting binary contains all code (even if it is not used)

Beside the input object files, which are obviously dependencies for the ELF binary, the `executable()` function also takes an additional `link_depends` and `link_whole` parameter. The `link_depends` parameter specifies a simple dependcy to the linker file. Therefore, the link process is also started when the Linker file has changed. The `link_whole`parameter specifies a list of libraries which should be linked to the target. These libraries are therefore also a dependency.

The second build target `stage1_link_bin` is used to create a raw binary file for the Stage 1 Bootloader out of the generated ELF binary. As already mentioned, this has the advantage that the Linker is able to optimize the ELF binary and provide debug information. For the raw binary we only extract specific sections from the ELF binary with the help of the tool `objcopy` and the usage of a Meson custom target with the function `custom_target()`

The Meson function `executable()` (used to create the ELF binary) uses the GCC Linker and not directly `ld`. Therefore, the Linker options must be specified with a different command line syntax.
If there is a `-Wl,<SomeOption>`, this setting is directly for the Linker which is called by GCC and if the `-Wl,`is missing, the options is directly passed to GCC.

### Linker Options for ELF Targets
The following table list the used Linker Options for the ELF target of the Stage 1 Bootloader

| Options                        | Description                                       |
| ------------------------------ | ------------------------------------------------- |
| `-Wl,-melf_i386`               | Instructs the Linker to generate a 32-bit ELF target for x86 |
| `-Wl,--gc-sections`            | Instructs the Linker to perform garbage collection of unused sections and remove them from ELF binary |
| `-g`                           | Keep Debug-Information in the ELF binary |
| `--function-sections`          | Option for GCC (in case we compile C-Sourcefiles for the target), to generate a separate section for each function. This is needed for a working garbage collection of the Linker |
| `--data-sections`              | Option for GCC (in case we compile C-Sourcefiles for the target), to generate a separate section for each global variable. This is needed for a working garbage collection of the Linker |
| `-nodefaultlibs`               | Prevents the GCC Linker to link standard system libraries |
| `-nostdlib`                    | Prevents the GCC Linker to link standard system startup files |
| `-nostartfiles`                | Prevents the GCC Linker to link standard system startup files |
| `-nolibc`                      | Prevents the GCC Linker to link standard C library |
| `-Os`                          | Set the optimization level for the C-Compiler to _optimize for size_ |


## Using Meson
The section will provide some commandline options for Meson to prepare and build the targets

Due to the fact that Meson is a kind of "Meta-Build System", Meson is not able to run the build commands by its own. Instead it generates build files, based on the Meson Build-File, for the Ninja Build System. Therefore, you need Meson **and** Ninja to run a build.

**Prepare Build Directory**
To prepare a Meson build and generate the Ninja build files, the following command can be used

`$ meson setup <Directory>`

Hereby, `<Directory>` specifies the build directory where all build files will be generated and where also all build artifacts will be stored. Meson uses in this case _out-of-source builds_

**Clean Build Directory**
To clean the build directory and all build artifacts, the following Ninja command can be used

`$ ninja clean`

This target deletes all object files and also all other, generated files in the build directory.

**Verbose Output**
For debugging purposes, Meson can output all commands which are executed during a build. The following Ninja commandline provides verbose output of the commands

`$ ninja -v <BuildTarget>`

Hereby, `<BuildTarget>` might be any valid build target

**Get a list of Build-Targets**
To get a list of all available build targets inside a Meson build, the following commandline can be used

`$ ninja -t targets`

This outputs a list of available targets. The following snippet shows an example for the StudyOS project

```
floppy: phony
fs: phony
stage1: phony
stage2: phony
biosapi: phony
test: phony
benchmark: phony
install: phony
dist: phony
scan-build: phony
TAGS: phony
ctags: phony
uninstall: phony
clean: phony
build.ninja: REGENERATE_BUILD
reconfigure: REGENERATE_BUILD
```
This target list includes implicit targets like clean, explicit targets like stage1 (defined via an alias)