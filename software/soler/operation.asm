;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

;===============================================================================
; wejście:
;	ax - wartość z klawiatury bądź myszki
soler_operation:
	; zachowaj oryginalne rejestry
	push	rax

	; suma operacji?
	cmp	ax,	"+"
	je	.add	; tak

	; różnica operacji?
	cmp	ax,	"-"
	je	.sub	; tak

	; iloczyn operacji?
	cmp	ax,	"*"
	je	.multiply	; tak

	; iloraz operacji?
	cmp	ax,	"/"
	je	.divide	; tak

	; przerworzyć?
	cmp	ax,	"="
	je	.result	; tak

	; modyfikacja wartości?
	cmp	ax,	STATIC_SCANCODE_DIGIT_0
	jb	.end	; nie
	cmp	ax,	STATIC_SCANCODE_DIGIT_9
	ja	.end	; nie

	; zamień scancode na cyfrę
	and	byte [rsp],	STATIC_BYTE_LOW_mask

	; domyślnie dołącz cyfrę do pierwszej wartości
	mov	rcx,	r10

	; wybrano operację?
	test	r12b,	r12b
	jz	.no_operation	; nie

	; dołącz cyfrę do drugiej wartości
	mov	rcx,	r11

.no_operation:
	; zmień podstawę wartości
	mov	eax,	STATIC_NUMBER_SYSTEM_decimal
	mul	rcx

	; kombinuj cyfrę z wartością
	movzx	ecx,	byte [rsp]
	add	rcx,	rax

	; wybrano operację?
	test	r12b,	r12b
	jz	.first	; nie

	; aktualizuj wartość
	mov	r11,	rcx

	; wykonano operację
	jmp	.end

.first:
	; aktualizuj wartość
	mov	r10,	rcx

	; wykonano operację
	jmp	.end

.add:
.sub:
.multiply:
.divide:
.result:

.end:
	; przywróć oryginalne rejestry
	pop	rax

	; powrót z procedury
	ret