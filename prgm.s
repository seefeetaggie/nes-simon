;By Darkdragon

.segment "HEADER"

	.byte $4E, $45, $53, $1A	; NES identification string
	.byte $02					; Number of 16KB units of PRG ROM
	.byte $01					; Number of 8KB units of CHR ROM
	.byte %00000000				; Set least significant bit to 0 for horizontal mirroring
	.byte $00					; Set to 0 to designate an iNES header
	.byte $00, $00, $00, $00	; pad the rest with zeros to make 16 bytes total
	.byte $00, $00, $00, $00

PPUDATA = $2007
FLASHDISPLAY = $3c

.segment "ZEROPAGE"
timer: .RES 1
button: .RES 1
control: .RES 1

.segment "STARTUP"


NMI:
;60 times/s
;read controller
	LDA control
	BEQ ROBOTCONTROL
	JSR BUTTONS
	JMP BUTTONREST
ROBOTCONTROL:	
	JSR Robots_turn
BUTTONREST:
;MAKE BUTTONS GLOW
	JSR SETCOLORS
	JSR SCROLL
	RTI

IRQ: RTI

RST: 
;prgm startup
	SEI		;disable IRQ INTRPT
	CLD 	;clear decimal mode
	LDX #$FF
	TXS		;set stack pointer FF
LOOP: BIT $2002
	BPL LOOP
LOOP2: BIT $2002
	BPL LOOP2
;BUTTON TIMER
	LDA #FLASHDISPLAY
	STA timer
	
; set the NMI flag in the PPUCTRL register
	LDA #%10000000
	STA $2000		; PPUCTRL
;SCREEN OFF
	LDA #%00000000  ; Show background only, no sprites
	STA $2001		;PPUMASK
	BIT $2002		;PPUSTATUS

;BACKGROUND
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006

COLOUR:
	JSR SETCOLORS

;.img in bk
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	LDX #$00
TILES:
	LDA simon, X
	STA PPUDATA
	INX
	BNE TILES

TILES2:
	LDA simon+$100, X
	STA PPUDATA
	INX
	BNE TILES2

TILES3:
	LDA simon+$200, X
	STA PPUDATA
	INX
	BNE TILES3

TILES4:
	LDA simon+$300, X
	STA PPUDATA
	INX
	BNE TILES4

; SCREEN ON
	LDA #%00001010  ; Show background only, no sprites
	STA $2001		;PPUMASK
	JSR SCROLL

	LDA #%00000001
	STA $4015

INF: JMP INF	;infinite loop
; end of setup

PALETTE1:
;COPY BUTTON COLORS TO PPU
;LDX BEFORE CALLING THIS
	LDA COLOR, X
	STA PPUDATA
	LDA COLOR+1, X
	STA PPUDATA
	LDA COLOR+2, X
	STA PPUDATA
	LDA COLOR+3, X
	STA PPUDATA
	RTS

BUTTONS:
; read controller
  lda #$01
  sta button
  sta $4016
  lda #$00
  sta $4016
start_me:
  lda $4016
  lsr a
  rol button
  bcc start_me
  RTS
  
SETCOLORS:
;SET PPU ADDRESS
;START PALETTE
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006
 ;DOWN BUTTON COLORS
	LDX #$00
	LDA button
	AND #%00000100
	BEQ DOWN_CONTINUE
	LDX #$10
DOWN_CONTINUE:
	JSR PALETTE1
;UP BUTTON COLORS
	LDX #$04
	LDA button
	AND #%00001000
	BEQ UP_CONTINUE
	LDX #$14
UP_CONTINUE:
	JSR PALETTE1

;LEFT BUTTON COLORS
	LDX #$08
	LDA button
	AND #%00000010
	BEQ LEFT_CONTINUE
	LDX #$18
LEFT_CONTINUE:
	JSR PALETTE1

;RIGHT BUTTON COLORS
	LDX #$0C
	LDA button
	AND #%00000001
	BEQ RIGHT_CONTINUE
	LDX #$1C
RIGHT_CONTINUE:
	JSR PALETTE1
	RTS

Robots_turn:
	DEC timer
	BNE ENDTURN
	LDA #FLASHDISPLAY
	STA timer
	LDA #%00000010
	EOR button
	STA button
ENDTURN:
	RTS

SCROLL:
	LDA #%10000000
	STA $2000		; PPUCTRL
	LDA $2002	; RESET SCROLL
	LDA #$00
	STA $2005	; HORIZONTAL SCROLL
	STA $2005	;VERTICAL SCROLL
	RTS

.segment "RODATA"

BK = $0F

COLOR:
DARK:
	.byte BK,$28,$18,$38    ; X = 0 = $00 \/
	.byte BK,$11,$01,$21	; X = 4	= $04  /\
	.byte BK,$16,$06,$26	; X = 8 = $08   <
	.byte BK,$19,$09,$29	; X = 12 = $0C  >
LIGHT:
	.byte BK,$38,$28,$38	; X = 16 = $10 \/
	.byte BK,$21,$11,$21	; X = 20 = $14 /\
	.byte BK,$26,$16,$26	; X = 24 = $18  <
	.byte BK,$29,$19,$29	; X = 28 = $1C  >

	; .byte BK, $27, $29, $14
	; .byte BK, $28, $34, $2B
	; .byte BK, $08, $10, $24
	; .byte BK, $00, $04, $2C
	; .byte BK, $01, $34, $03
	; .byte BK, $04, $00, $14
	; .byte BK, $3A, $00, $02
	; .byte BK, $20, $2C, $08

	.include "simon.asm"

.segment "VECTORS"

	.addr NMI, RST, IRQ

.segment "CHARS"

	.incbin "simon.chr"
