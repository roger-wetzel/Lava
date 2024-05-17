; SPREADPOINT
; LAVA (AMIGA, PAL, OCS, 68000, >= 256 KB)
; (C) 2024 DEPECHE

; Build with vasm
; vasmm68k_mot -kick1hunks -Fhunkexe -o lava -nosym lava.s

bitplane	equ	$60000			; lower word must be $0000
pwidth		equ	80
sinlen		equ	256
numlines	equ	256
deltaa		equ	2
deltab		equ	4

	code_c

	lea	clist(pc),a5			;

	; generate bitplane row pattern (1 row is enough)
	lea	bitplane,a0			;
	moveq	#40-1,d7			; 40*8 = 320px
.row	sf	pwidth/2(a0)			;
	st	(a0)+				;
	dbf	d7,.row				;

	; generate sin table (by gigabates)
	lea	$4000(a5),a0			;
	move.l	a0,a3				; used later in main
	moveq	#0,d0				;
	move.w	#sinlen/2+1,a1			;
.gensin	subq.l	#2,a1				;
	move.l	d0,d1				;
	asr.l	#6,d1				; this determines the amplitude
	move.w	d1,(a0)+			;
	neg.w	d1				;
	move.w	d1,sinlen-2(a0)			;
	add.l	a1,d0				;
	bne	.gensin				;

.main	tst.b	$dff006				; wait raster (might fire twice per frame)
	bne	.main				;

	lea	clistinsert-clist(a5),a0	;
	move.l	#$2bdffffe,d5			;
	move.w	#numlines-1,d7			;
.update	move.l	d5,(a0)+			; wait
	add.l	#$01000000,d5			; next line

	move.w	#$00e2,(a0)+			; bitplane pointer
	move.w	#$01fe,d4			;
	and.w	d4,d0				; (d0 is not initialized)
	move.w	(a3,d0.w),d6			;
	and.w	d4,d1				; (d1 is not initialized)
	add.w	(a3,d1.w),d6			;
	and.w	d4,d6				;
	moveq	#127,d4				; "middle" of bitplane
	add.w	(a3,d6.w),d4			;
	move.w	d4,d3				;
	asr.w	#3,d3				;
	move.w	d3,(a0)+			;

	move.w	#$0102,(a0)+			; horizontal shift
	moveq	#$f,d3				;
	and.w	d3,d4				;
	sub.w	d4,d3				;
	move.w	d3,(a0)+			;

	addq.w	#deltaa,d0			;
	addq.w	#deltab,d1			;
	dbf	d7,.update			;

	moveq	#-2,d3				;
	move.l	d3,(a0)				; end of clist

	sub.w	#(numlines-2)*deltaa+6,d0	; (-2 = vertical velocity)
	sub.w	#(numlines-2)*deltab+2,d1	;

	move.l	a5,$dff080			;
	bra	.main				;

clist	dc.w	$009a,$7fff
	dc.w	$0096,$0020			; sprites off
	dc.w	$008e,$2c91
	dc.w	$0090,$2cc1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0
	dc.w	$00e0,bitplane>>16
	dc.w	$0100,$1200
	dc.w	$0180,$0330
	dc.w	$0182,$0ee0
clistinsert
