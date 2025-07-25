# QEmu
If you want to develop an OS or another low-level software, an emulation environment to emulate the real hardware is very helpful. One of my favorit emulators is [QEmu](https://www.qemu.org/). It provides the emulation of standard x86 systems including all modern processor variants but also bare-metal embedded system with ARM microcontroller. Additionally, QEmu provides an integrated GDB Server to easily debug the system.

## x86 Real-Mode
One issue when debugging an OS respectively a bootloader early in the boot process, is the Real-Mode of the x86 processor. Due to backward compatibility of all x86 processors with the original Intel 8086, the x86 starts in 16 Bit Real-Mode. If you write a bootloader, at least the bootloader for the master boot record must be 16 Bit code (it might later switch to 32 Bit protected mode). Hereby, QEmu in combination with GDB is not working perfectly because of the segmented memory model of the x86 in Real-Mode and the returned _architecture_ from QEmu.

To overcome this issue, multiple workarounds exist in the Internet. But to be honest, the only way which works really good (at least from my oppinion) is:
 * Using a patched QEmu version for Real-Mode
 * Using the original QEmu version for Protected-Mode

I'm using Eclipse as a GDB frontend and therefore I also have two different debug configurations for Real- and Protected-Mode.

A very good explanation of the issue and the possible workarounds can be found in a short article from [Theldus (Devidson Francis)](https://gist.github.com/Theldus). He wrote an article [The only proper way to debug 16-bit code on Qemu+GDB](https://gist.github.com/Theldus/4e1efc07ec13fb84fa10c2f3d054dccd) where he describes the solution with patching QEmu. The article is refering to QEmu 8.2 respectivly 9.2.50. If modified the patch to work with QEmu version 10.0.0

```patch
diff -ruN qemu-10.0.0/target/i386/cpu.c qemu-10.0.0_patch/target/i386/cpu.c
--- qemu-10.0.0/target/i386/cpu.c	2025-04-22 22:26:11.000000000 +0200
+++ qemu-10.0.0_patch/target/i386/cpu.c	2025-07-20 12:52:23.981854557 +0200
@@ -6684,7 +6684,22 @@
 #ifdef TARGET_X86_64
     return "i386:x86-64";
 #else
-    return "i386";
+    //return "i386";
+    X86CPU *cpu = X86_CPU(cs);
+    CPUX86State *env = &cpu->env;
+
+    /*
+     * ## Handle initial CPU architecture ##
+     *
+     * Check if protected mode or real mode.
+     * This is only useful when the GDB is attaching,
+     * mode switches after that aren't reflected
+     * here.
+     */
+    if (env->cr[0] & 1)
+      return "i386";
+    else
+      return "i8086";
 #endif
 }
```

```patch
diff -ruN qemu-10.0.0/target/i386/gdbstub.c qemu-10.0.0_patch/target/i386/gdbstub.c
--- qemu-10.0.0/target/i386/gdbstub.c	2025-04-22 22:26:11.000000000 +0200
+++ qemu-10.0.0_patch/target/i386/gdbstub.c	2025-07-20 12:59:40.112900621 +0200
@@ -136,7 +136,22 @@
                 return gdb_get_regl(mem_buf, 0);
             }
         } else {
-            return gdb_get_reg32(mem_buf, env->regs[gpr_map32[n]]);
+            //return gdb_get_reg32(mem_buf, env->regs[gpr_map32[n]]);
+            /*
+             * ## Handle ESP ##
+             * If in protected-mode, do as usual...
+             */
+            if (env->cr[0] & 1) {
+                return gdb_get_reg32(mem_buf, env->regs[gpr_map32[n]]);
+            }
+
+            /* If real mode & !ESP, do as usual... */
+            if (n != R_ESP) {
+                return gdb_get_reg32(mem_buf, env->regs[gpr_map32[n]]);
+            }
+
+            /* If ESP, return it converted. */
+            return gdb_get_reg32(mem_buf, (env->segs[R_SS].selector * 0x10) + env->regs[gpr_map32[n]]);
         }
     } else if (n >= IDX_FP_REGS && n < IDX_FP_REGS + 8) {
         int st_index = n - IDX_FP_REGS;
@@ -155,7 +170,21 @@
     } else {
         switch (n) {
         case IDX_IP_REG:
-            return gdb_get_reg(env, mem_buf, env->eip);
+            //return gdb_get_reg(env, mem_buf, env->eip);
+            {
+                /*
+                 * ## Handle EIP ##
+                 * qemu-system-i386 is handled here!
+                 */
+
+                /* If in protected-mode, do as usual... */
+                if (env->cr[0] & 1) {
+                    return gdb_get_reg(env, mem_buf, env->eip);
+                /* Otherwise, returns the physical address. */
+                } else {
+                    return gdb_get_reg32(mem_buf, (env->segs[R_CS].selector * 0x10) + env->eip);
+                }
+            }
         case IDX_FLAGS_REG:
             return gdb_get_reg32(mem_buf, env->eflags);
```

After applying the patches, I built QEmu with the following commands
```
$ ./configure
$ make -j6
```

I didn't install the patched version of QEmu. Instead I specified the path to the QEmu version in the Eclipse "External Tool Configuration" for QEmu in Real-Mode.

## Protected Mode
For debugging in Protected-Mode I've used the original, unpachted version of QEmu 10.0.0. In general, you can also debug with the patched version of QEmu the Protected-Mode part. Even the jump from Real-Mode to Protected-Mode works pretty good. The only issue I had was, that I was only able to debug with source-level information and not the disassembly view from GDB. The reason was (at least what I could figure out), that GDB is not disassemblign correctly (even if you set the GDB architecture manually). It looks like that his has to do with the modified Instruction Pointer register in the GDB stub because after setting the GDT, GDB is somehow disassembling the wrong memory sections.