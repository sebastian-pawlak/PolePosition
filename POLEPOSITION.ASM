; "Pole Position", Atari XL/XE Intro 256B
;
; A tribute to classic video game of the same title.
;
; I dedicate this prod to my little son, who probably likes cars
; (he often repeats "vroom, vroom").
;
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2021-08-21

rtclok	equ $0012
rowcrs	equ $0054
colcrs	equ $0055
oldrow	equ $005a
oldcol	equ $005b
sdmctl	equ $022f
gprior	equ $026f
pcolr0	equ $02c0
pcolr1	equ $02c1
color0	equ $02c4
atachr	equ $02fb
hposp0	equ $d000
hposp1	equ $d001
sizep0	equ $d008
sizep1	equ $d009
colpf1	equ $d017
colbk	equ $d01a
gractl	equ $d01d
audf1	equ $d200
audc1	equ $d201
pmbase	equ $d407
wsync	equ $d40a
vcount	equ $d40b
osgraph	equ $ef9c
osprint	equ $f1a4
ospoint	equ $f1d8
osdraw	equ $f9c2


	org $0080

	bvc start

	; draw the road routine
road	lda #$46
	sta oldrow
	sta oldcol
	inc colcrs
	lda #$bf
	sta rowcrs
	jsr osdraw
	sta oldcol			; A=$01 after "jsr osdraw"
	dec start
	bne road
	rts

	; draw mountains, draw clouds routine
draw
opcoda1	lda #$4b
	sta rowcrs
opcoda2	*
loopa1	lda #$1e
	asl
	bcc skipa1
	eor #$4d
skipa1	sta opcoda2+1
	ror
	dec rowcrs
	bcc skipa2
	inc rowcrs
	inc rowcrs
skipa2	lda rowcrs
	eor #%000111111
	lsr
opcoda3	lda #$4b
	sta oldrow
	jsr osdraw
	inc colcrs
	inc oldcol
	bne loopa1
	rts

start	lda #$0f
	jsr osgraph

	; draw the road
	iny				; Y=1 after "jsr osgraph"
	sty atachr
	jsr road
	lda #$7e
	sta hposp0			; PMG
	sta hposp1			; PMG
	sta gractl			; PMG
	sta sdmctl			; PMG
	sta start
	dec atachr
	lda #$11
	sta colcrs
	jsr road

	ldy #$04
	sty color0
	dey
	sty pcolr1

	; draw mountains
	sty atachr
	stx colcrs
	jsr draw

	; PMG
	lda #$1c
	sta pcolr0
	lda #$23
	sta gprior

	lda #$63
	sta audc1			; sound
	sta audf1			; sound
	sta pmbase			; PMG
	sta sizep0			; PMG
	sta sizep1			; PMG

	; draw clouds
	lda #$c6			; "dec" opcode, erase previous command
	sta opcoda3
	sta atachr
	lda #$19
	sta opcoda1+1
	jsr draw

	; colors, animation
loopb1	ldy vcount
	ldx #$8a
	lda #$0f
	cpy #$35
	bmi skipb2
	ldx #$b8
	tya				; lda vcount
	sbc rtclok+2
	and #%00001000
	beq skipb1
	ora #$0f
	bne skipb2
skipb1	ora #$24
skipb2	;sta wsync			; not necessary
	stx colbk
	sta colpf1
	bne loopb1			; infinite loop


	org $6300+$01bd

car1	.byte $18, $18, $3c, $3c, $24, $3c, $24, $24, $24, $7e, $7e, $3c, $3c
	.byte $3c, $3c, $24, $3c, $24, $3c, $24, $3c, $24


	org $6300+$02bd

car2	.byte $18, $5a, $66, $66, $7e, $66, $7e, $7e, $7e, $7e, $7e, $e7, $e7
	.byte $c3, $c3, $db, $db, $db, $db, $db, $db, $db, $c3, $c3