/*
 * Programmable Interval Controller Module
 * Provides functions to configure the PIT
 *
 */

.intel_syntax noprefix

#include "pm_pit_defines.asm"


/*
 * Initializes the PIT to the specified frequency
 *
 * void pmPITInitialize(struct PIT_DATA* pData, int16_t freq);
 *
 * Parameters:
 *    EBP + 8:  pData
 *    EBP + 12: freq
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPITInitialize,"ax",@progbits
.global pmPITInitialize
pmPITInitialize:
    push ebp
    mov ebp, esp

    pushad
    push ebx
    push edx
    push edi

    mov ebx, [ebp + 12]                         /* Get the frequency from stack */
    mov eax, PIT_MAX_DIV                        /* Prepare eax with max divider value (PIT_MAX_DIV) */
    cmp ebx, PIT_MIN_FREQ                       /* PIT_MIN_FREQ */

    /* If freq <= PIT_MIN_FREQ, use the max divider value for reload */
    jbe pmPITInitialize_gotReloadValue

    mov eax, 1                                  /* Prepare eax with the min divider --> max frequency */
    cmp ebx, PIT_FREQUENCY
    /* If freq >= PIT_FREQUENCY, use the min divider of 1 */
    jae pmPITInitialize_gotReloadValue

    /* If freq > 18 Hz and freq < PIT_FREQUENCY, calculate the reload value */
    mov eax, PIT_FREQUENCY
    mov edx, 0
    div ebx                                     /* eax = PIT_FRQUENCY / freq, edx = reminder */

    /* Perform rounding for better accuracy */
    cmp edx, PIT_FREQUENCY / 2                  /* PIT_FREQUENCY / 2 */
    jb pmPITInitialize_gotReloadValue
    /* Round up */
    inc eax

pmPITInitialize_gotReloadValue:
    /* Store reload value in structure */
    mov edi, [ebp +8]
    mov WORD PTR [edi + PIT_DATA_RELOAD_VALUE_OFF], ax  /* PIT_DATA_RELOAD_VALUE_OFF */

    /* Calculate frequency from reload value */
    mov ebx, eax                                /* ebx = Reload Value */
    mov eax, PIT_FREQUENCY                      /* eax = PIT_Frequency */
    mov edx, 0
    div ebx                                     /* eax = eax / ebx, reminder = edx */

    /* Store backward calculated frequency in struct */
    mov edi, [ebp + 8]
    mov [edi + PIT_DATA_IRQ0_FREQ_OFF], eax     /* PIT_DATA_IRQ0_FREQ_OFF */

    /* Program the PIT Channel */
    pushfd
    cli

    /* pmPortOutByte(PIT_MODE_CMD_REG, (CMD_SEL_CHANNEL_0 | CMD_ACCESS_MODE_LOHI | CMD_OP_MODE_2 | CMD_BIN_MODE)); */
    push (CMD_SEL_CHANNEL_0 | CMD_ACCESS_MODE_LOHI | CMD_OP_MODE_2 | CMD_BIN_MODE)
    push PIT_MODE_CMD_REG
    call pmPortOutByte
    add esp, 8

    xor eax, eax
    mov edi, [ebp + 8]
    mov ax, WORD PTR [edi + PIT_DATA_RELOAD_VALUE_OFF]  /* ebp + 8 + PIT_DATA_RELOAD_VALUE_OFF */
    mov ebx, 0
    mov bl, al

    /* pmPortOutByte(PIT_CH0_DATA_REG, PIT_reloadValue & 0x00FF); */
    push ebx
    push PIT_CH0_DATA_REG
    call pmPortOutByte
    add esp, 8

    mov ebx, 0
    mov bl, ah

    /* pmPortOutByte(PIT_CH0_DATA_REG, PIT_reloadValue & 0xFF00); */
    push ebx
    push PIT_CH0_DATA_REG
    call pmPortOutByte
    add esp, 8

    popfd

    pop edi
    pop edx
    pop ebx
    popad

    leave
    ret