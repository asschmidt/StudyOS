/*
 * IDT Functions used to prepare and use the IDT in Protected Mode
 *
 *
 */

.intel_syntax noprefix

/*
 * Prepares the IDT descriptor with correct pointer and size information for IDT
 *
 * void pmPrepareIDT(uint32_t* pIDTDesc, uint32_t* pIDT, uint16_t entryCount, int16_t segment);
 *
 * Parameters:
 *    SP + 8:  pIDTDesc
 *    SP + 12: pIDT
 *    SP + 16: entryCount
 *    SP + 20: segment
 *
 * Return:
 *    -
 *
 */
.code32
.section .text.pmPrepareIDT,"ax",@progbits
.global pmPrepareIDT
pmPrepareIDT:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push esi
    push edi

    /* Get pointer to IDT descriptor from parameter stack */
    mov esi, [ebp + 8]
    /* Get pointer to IDT from parameter stack */
    mov eax, [ebp + 12]
    /* We need to calculate the linear address for the IDT */
    /* Therefore load the segement address and calculate linear address */
    mov ebx, [ebp + 20]
    shl ebx, 4
    add eax, ebx
    /* Store IDT pointer in IDT descriptor */
    mov [esi + 2], eax
    /* Get entryCount from parameter stack */
    mov eax, [ebp + 16]
    /* Calculate size of table size = (entryCount * 8) - 1 */
    shl eax, 3
    dec eax
    /* Store size in IDT descriptor */
    mov [esi], ax

    pop edi
    pop esi
    pop ebx
    pop eax

    leave
    ret

/*
 * Sets up an IDT entry in the IDT
 *
 * void pmSetupIDTEntry(uint32_t* pIDT, uint8_t idtIdx, uin32_t pFunc, uint8_t typeAttribute, uint16_ segSelector);
 *
 *    Parameters:
 *      SP + 8:  pIDT
 *      SP + 12: idtIdx
 *      SP + 16: pFunc
 *      SP + 20: typeAttribute
 *      SP + 24: segSelector
 *
 *    Returns:
 *      EAX: Error Code (1=Error, 0=Success)
 *
 */
.code32
.section .text.pmSetupIDTEntry,"ax",@progbits
.global pmSetupIDTEntry
pmSetupIDTEntry:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edx
    push esi
    push edi

    /* Get index from parameter stack */
    mov ebx, [ebp + 12]

    /* Check for Index > 0 and Index <= 255 */
    cmp ebx, 0x00
    jl .failed_pmSetupIDTEntry
    cmp ebx, 0xFF
    jg .failed_pmSetupIDTEntry

    /* Get pIDT from parameter stack */
    mov edi, [ebp + 8]
    /* Move EDI to the position in the table based on the index */
    shl ebx, 3
    add edi, ebx
    /* Get function pointer value from parameter stack */
    mov ecx, [ebp + 16]
    /* Store lower 16 bit from function pointer in first offset field */
    mov [edi], cx
    /* Store upper 16 bit from function pointer in second offset field */
    shr ecx, 16
    and ecx, 0x0000FFFF
    mov [edi + 6], cx
    /* Store Segment Selector */
    mov ebx, [ebp + 24]
    mov [edi + 2], bx
    /* Store Type */
    mov ebx, [ebp + 20]
    shl bx, 8
    and ebx, 0x0000FF00
    mov [edi + 4], bx

	xor eax, eax
	jmp .finished_pmSetupIDTEntry

.failed_pmSetupIDTEntry:
	mov eax, 0x1

.finished_pmSetupIDTEntry:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx

    leave
    ret



