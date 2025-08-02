project('StudyOS', 'c', 'cpp', version: '0.0.1', meson_version: '1.8.3')


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

###############################################################################
# Support Targets to generate Images/Floppy/Filesystem
###############################################################################
boot_floppy_image = 'boot_floppy.img'


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
    output: '@BASENAME@.i.asm',
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

###############################################################################
# Lib LowLevel
###############################################################################
lib_lowlevel_asm_gen = generator(gas,
    output: '@BASENAME@.o',
    arguments: [gas_args_32bit,
                '-I', lib_lowlevel_inc,
                '-I', lib_bios_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

lib_lowlevel_asm_preproc = generator(cpp,
    output: '@BASENAME@.i.asm',
    arguments: [cpp_args,
                '-I', lib_bios_inc,
                '-I', lib_lowlevel_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

# Setup the C-Source Files for the Lowlevel Lib
lib_lowlevel_c_source_files = files(lib_lowlevel_dir + 'common_structs.c')

# Setup the ASM-Source Files for the LowLevel Lib
lib_lowlevel_source_files = files(lib_lowlevel_dir + 'pm_stdio.asm')
lib_lowlevel_source_files += files(lib_lowlevel_dir + 'pm_gdt.asm')
lib_lowlevel_source_files += files(lib_lowlevel_dir + 'pm_idt.asm')
lib_lowlevel_source_files += files(lib_lowlevel_dir + 'pm_gpio.asm')
lib_lowlevel_source_files += files(lib_lowlevel_dir + 'pm_pic.asm')

# Preprocess the ASM files
lib_lowlevel_preproc_files = lib_lowlevel_asm_preproc.process(lib_lowlevel_source_files)

# Assemble the ASM source files to object files
lib_lowlevel_object_files = lib_lowlevel_asm_gen.process(lib_lowlevel_preproc_files)

# Create the static library for liblowlevel
lib_lowlevel = static_library('lowlevel',
                    c_args: ['-m32'],
                    sources: lib_lowlevel_c_source_files,
                    objects: lib_lowlevel_object_files)


###############################################################################
# Lib Env
###############################################################################
lib_env_asm_gen = generator(gas,
    output: '@BASENAME@.o',
    arguments: [gas_args_32bit,
#                '-I', lib_lowlevel_inc,
#                '-I', lib_bios_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

lib_env_asm_preproc = generator(cpp,
    output: '@BASENAME@.i.asm',
    arguments: [cpp_args,
                '-I', lib_bios_inc,
                '-I', lib_lowlevel_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

# Setup the C-Source Files for the Env Lib
lib_env_c_source_files = files(lib_env_dir + 'env_structs.c')
#lib_env_c_source_files += files(lib_env_dir + 'common_structs.c')

# Setup the ASM-Source Files for the Env Lib
lib_env_source_files = files(lib_env_dir + 'memory.asm')

# Preprocess the ASM files
lib_env_preproc_files = lib_env_asm_preproc.process(lib_env_source_files)

# Assemble the ASM source files to object files
lib_env_object_files = lib_env_asm_gen.process(lib_env_preproc_files)

# Create the static library for liblowlevel
lib_env = static_library('env',
                    c_args: ['-m32'],
                    sources: lib_env_c_source_files,
                    objects: lib_env_object_files)


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

stage1_asm_preproc = generator(cpp,
    output: '@BASENAME@.i.asm',
    arguments: [cpp_args,
                '-I', lib_bios_inc,
                '-I', lib_lowlevel_inc,
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

# Preprocess the ASM files
stage1_preproc_files = stage1_asm_preproc.process(stage1_source_files)

# Generate the Object Files for Stage1
stage1_object_files = stage1_asm_gen.process(stage1_preproc_files)

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


###############################################################################
# Stage2 Boootloader
###############################################################################
# Define the ASM Generator for Stage 2
stage2_asm_gen = generator(gas,
    output: '@BASENAME@.o',
    arguments: [gas_args_32bit,
                '-I', lib_lowlevel_inc,
                '-I', lib_bios_inc,
                '-I', lib_env_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

stage2_asm_preproc = generator(cpp,
    output: '@BASENAME@.i.asm',
    arguments: [cpp_args,
                '-I', lib_bios_inc,
                '-I', lib_lowlevel_inc,
                '-I', lib_env_inc,
                '@INPUT@',
                '-o', '@OUTPUT@'])

# Define the output filenames for Stage2 Raw Binary incl. a Map file
stage2_bin_output       = 'boot_stage2_bin'
stage2_bin_output_map   = stage2_bin_output + '.map'

# Define the output filenames for Stage2 ELF incl. a Map file
# This is used to provide debugging symbols for the debugger and the additional
# Map File can be used to cross check the binary/elf output of the Linker
stage2_elf_output      = 'boot_stage2_elf'
stage2_elf_output_map   = stage2_elf_output + '.map'

# Define the Bootloader Stage2 Sources
stage2_source_dir   = 'src/bootloader/stage2/'
stage2_source_files = files(stage2_source_dir + 'stage2.asm')
stage2_source_files += files(stage2_source_dir + 'stage2_gdt.asm')
stage2_source_files += files(stage2_source_dir + 'stage2_idt.asm')
stage2_source_files += files(stage2_source_dir + 'kernel_gdt.asm')
stage2_source_files += files(stage2_source_dir + 'pm.asm')

# Preprocess the ASM files
stage2_preproc_files = stage2_asm_preproc.process(stage2_source_files)

# Generate the Object Files for Stage2
stage2_object_files = stage2_asm_gen.process(stage2_preproc_files)

#
# Setup Linker related options
#

# Linker File to use for stage2
stage2_linker_file  = files(stage2_source_dir + 'stage2.ld')

# Linker arguments used for all targets
stage2_linker_args  = ['-Wl,-no-pie', '-Wl,-melf_i386', '-Wl,--gc-sections', '-g', '--function-sections', '--data-sections', '-nodefaultlibs', '-nostdlib', '-nostartfiles', '-nolibc', '-Os']
# Linker arguments used to generate the Raw Binary
stage2_bin_linker_args  = stage2_linker_args + ['-Wl,--oformat=binary']
# Linker arguments used to gernerate the ELF
stage2_elf_linker_args  = stage2_linker_args + ['-Wl,--oformat=elf32-i386']


#
# Build Target to create the ELF for Stage1
#
stage2_link_elf     = executable(stage2_elf_output, stage2_object_files,
                        name_suffix: 'elf',
                        link_args : [stage2_elf_linker_args,
                                   '-Wl,-Map,' + stage2_elf_output_map,
                                   '-T', stage2_linker_file[0].full_path()
                                    ],
                        link_depends: stage2_linker_file,
                        link_whole: [lib_bios, lib_lowlevel, lib_env])

#
# Generate a Floppy-Image (1,44 MB) incl. partitions
#
stage2_link_bin   = custom_target(stage2_bin_output,
                        input: [stage2_link_elf],
                        output: [stage2_bin_output + '.bin'],
                        command: [objcopy,
                                  '-O', 'binary',
                                  '--only-section=.text*',
                                  '--only-section=.rodata*',
                                  '--only-section=.data*',
                                  '--only-section=.gdt*',
                                  '@INPUT@',
                                  '@OUTPUT0@'],
                        depends: [stage2_link_elf])

###############################################################################
# Floppy and Filesystem Support Targets
###############################################################################

#
# Generate a Floppy-Image (1,44 MB) incl. partitions
#
gen_floppy_image   = custom_target('floppy',
                        output: [boot_floppy_image],
                        command: [bash,
                                  meson.current_source_dir() + '/tools/scripts/generate_floppy.sh',
                                  '@OUTPUT0@'],
                        build_always_stale: true)


#
# Setup the File-System on second partition of Floppy Image
# Unfortunately, the creation of the filesystem needs root-permission
# Therefore, the script is run with sudo
#
gen_file_system   = custom_target('filesystem',
                        input: [gen_floppy_image],
                        output: ['filesystem.log'],
                        command: [sudo, 'bash',
                                meson.current_source_dir() + '/tools/scripts/generate_fat.sh',
                                '@INPUT0@'],
                        #capture: true,
                        console: true,
                        depends: [gen_floppy_image])

#
# Target to write the Stage1 bootloader to the bootsector of the floppy image
#
stage1_update_floppy  = custom_target('stage1_to_floppy',
                        input   : [stage1_link_bin],
                        output  : ['stage1_floppy.log'],
                        command : [dd,
                                   'if=@INPUT0@',
                                   'of=' + meson.current_build_dir() + '/' + boot_floppy_image,
                                   'conv=notrunc',
                                   'seek=0'],
                        capture: true,
                        build_always_stale : true,
                        depends : [stage1_link_bin])


#
# Target to write the Stage2 bootloader to the partition on the floppy disk
#
stage2_update_floppy  = custom_target('stage2_to_floppy',
                        input   : [stage2_link_bin],
                        output  : ['stage2_floppy.log'],
                        command : [dd,
                                   'if=@INPUT0@',
                                   'of=' + meson.current_build_dir() + '/' + boot_floppy_image,
                                   'conv=notrunc',
                                   'bs=512',
                                   'seek=1'],
                        capture: true,
                        build_always_stale : true,
                        depends : [stage2_link_bin])

###############################################################################
# Alias Targets
###############################################################################

# Alias Target to generate the Floppy-Image
alias_target('floppy', [gen_floppy_image])
# Alias Target to generate the file system
alias_target('fs', [gen_file_system])

# Alias Target to build the Stage1 bootloader and put it on the bootsector of the image
alias_target('stage1', [stage1_update_floppy])
# Alias Target to build the Stage2 bootloader and put it on the partition on the disk
alias_target('stage2', [stage2_update_floppy])

alias_target('biosapi', [lib_bios])
alias_target('lowlevelapi', [lib_lowlevel])
alias_target('envapi', [lib_env])

