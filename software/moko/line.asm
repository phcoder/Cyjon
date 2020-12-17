;===============================================================================
; Copyright (C) Andrzej Adamczyk (at https://blackdev.org/). All rights reserved.
; GPL-3.0 License
;
; Main developer:
;	Andrzej Adamczyk
;===============================================================================

;===============================================================================
moko_line:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi

	; ustaw kursor na początek aktualnego wiersza przestrzeni znakowej
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out
	mov	ecx,	moko_string_cursor_at_begin_of_line_end - moko_string_cursor_at_begin_of_line
	mov	rsi,	moko_string_cursor_at_begin_of_line
	int	KERNEL_SERVICE

	; ustaw wskaźnik na początek/fragment linii do wyświetlenia
	mov	rsi,	r10
	sub	rsi,	r11
	add	rsi,	r12

	; ilość znaków z linii do wyświetlenia
	mov	rcx,	r13
	sub	rcx,	r12
	cmp	rcx,	r8
	jb	.visible	; ilość znaków mniejsza od szerokości ekranu

	; wyświetl maksymalną ilość znaków na ekran
	mov	rcx,	r8
	dec	rcx	; ostatnia kolumna zawsze pusta

.visible:
	; linia jest pusta?
	test	rcx,	rcx
	jz	.empty	; tak

	; wyświetl kolejno ciąg znaków o określonej długości
	int	KERNEL_SERVICE

	; zachowaj pozostały rozmiar linii
	push	rcx

	; zapamiętaj pozycję kursora
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out
	mov	ecx,	moko_string_cursor_save_end - moko_string_cursor_save
	mov	rsi,	moko_string_cursor_save
	int	KERNEL_SERVICE

	; przywróć pozostały rozmiar linii
	pop	rcx

.empty:
	; wyczyścić resztę linii?
	cmp	r8,	rcx
	je	.no	; nie

	; pozostałą część linii za pomocą znaku spacji
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out_char
	sub	rcx,	r8
	not	rcx	; zamień na wartość bezwzględną
	mov	dl,	STATIC_SCANCODE_SPACE
	int	KERNEL_SERVICE

.no:
	; ustaw pozycję kursora na aktualną pozycję
	mov	ax,	KERNEL_SERVICE_PROCESS_stream_out
	mov	ecx,	moko_string_cursor_restore_end - moko_string_cursor_restore
	mov	rsi,	moko_string_cursor_restore
	int	KERNEL_SERVICE

	; przywróć oryginalne rejestry
	pop	rsi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret
