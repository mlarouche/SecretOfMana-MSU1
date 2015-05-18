arch snes.cpu

// MSU memory map I/O
constant MSU_STATUS($002000)
constant MSU_ID($002002)
constant MSU_AUDIO_TRACK_LO($002004)
constant MSU_AUDIO_TRACK_HI($002005)
constant MSU_AUDIO_VOLUME($002006)
constant MSU_AUDIO_CONTROL($002007)

// SPC communication ports
constant SPC_COMM_0($2140)
constant SPC_COMM_1($2141)
constant SPC_COMM_2($2142)
constant SPC_COMM_3($2143)

// MSU_STATUS possible values
constant MSU_STATUS_TRACK_MISSING($8)
constant MSU_STATUS_AUDIO_PLAYING(%00010000)
constant MSU_STATUS_AUDIO_REPEAT(%00100000)
constant MSU_STATUS_AUDIO_BUSY($40)
constant MSU_STATUS_DATA_BUSY(%10000000)

// SNES Multiply register
constant SNES_MUL_OPERAND_A($004202)
constant SNES_MUL_OPERAND_B($004203)
constant SNES_DIV_DIVIDEND_L($004204)
constant SNES_DIV_DIVIDEND_H($004205)
constant SNES_DIV_DIVISOR($004206)
constant SNES_DIV_QUOTIENT_L($004214)
constant SNES_DIV_QUOTIENT_H($004215)
constant SNES_MUL_DIV_RESULT_L($004216)
constant SNES_MUL_DIV_RESULT_H($004217)

// Constants
if {defined EMULATOR_VOLUME} {
	constant FULL_VOLUME($60)
} else {
	constant FULL_VOLUME($FF)
}

// Game variables
variable MusicCommand($7E1E00)
variable RequestedSong($7E1E01)
variable PreviousSong($7E1E05)

// My variables
variable FadeState($7E1EDD)
variable FadeVolume($7E1EDE)
variable FadeStep($7E1EE0)
variable FadeTemp($7E1EE2)
variable FadeCount($7E1EE4)
variable FrameCount($7E1EE5)

// **********
// * Macros *
// **********
// seek converts SNES HiROM address to physical address
macro seek(variable offset) {
  origin (offset & $3FFFFF)
  base offset
}

macro CheckMSUPresence(labelToJump) {
	lda MSU_ID
	cmp.b #'S'
	bne {labelToJump}
}

macro WaitMulResult() {
	nop
	nop
	nop
	nop
}

macro WaitDivResult() {
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
}

// ********
// * Code *
// ********
seek($008008)
	jml Reset_Hijack
	
// Override NMI vector to call a custom RAM address
// with my hijack
seek($C0FFEA)
	db $22,$01
	
seek($C30004)
	jmp MSU_Hijack
	
seek($C324C0)
MSU_Hijack:
	jsl MSU_Main
	bcc ReturnToCode
	jmp $0160
	
ReturnToCode:
	rtl
	
// MSU code
seek($CB3400)
scope MSU_Main: {
	php
	rep #$30
	pha
	phx
	phy
	
	sep #$20
	CheckMSUPresence(OriginalCode)
	
	lda MusicCommand
	beq DoNothing

	cmp #$01
	bne +;
	stz MusicCommand
	jsr MSU_PlayMusic
	bcs OriginalCode
	bcc DoNothing
+;
	cmp #$80
	bne +;
	stz MusicCommand
	jsr MSU_Fade
	bra OriginalCode
+;
	cmp #$F1
	bne +;
	stz MusicCommand
	jsr MSU_Stop
+;
	
OriginalCode:
	rep #$30
	ply
	plx
	pla
	plp
	sec
	rtl

DoNothing:
	rep #$30
	ply
	plx
	pla
	plp
	clc
	rtl
}

scope MSU_PlayMusic: {
	// Check if the song is already playing
	xba
	lda $7E1E02
	and #$0F
	pha
	lda RequestedSong
	pha
	plx
	cpx PreviousSong
	beq Exit

	// Current current SPC song playing, if any
	jsr Stop_SPC

	// Set MSU-1 track
	lda RequestedSong
	sta MSU_AUDIO_TRACK_LO
	lda.b #$00
	sta MSU_AUDIO_TRACK_HI

IsMSUReady:
	lda MSU_STATUS
	and.b #MSU_STATUS_AUDIO_BUSY
	bne IsMSUReady
	
	// Check if the track is missing
	lda MSU_STATUS
	and.b #MSU_STATUS_TRACK_MISSING
	bne TrackMissing
	
	// Play the song and add repeat if needed
	//jsr TrackNeedLooping
	lda #$03
	sta MSU_AUDIO_CONTROL
	
	// Set volume
	lda.b #FULL_VOLUME
	sta MSU_AUDIO_VOLUME
	sta FadeVolume+1
	
	// Set previous song for game
	lda RequestedSong
	sta PreviousSong
	lda $7E1E02
	and #$0F
	sta $7E1E06
	lda $7E1E03
	sta $7E1E07
	
Exit:
	clc
	rts
	
TrackMissing:
	lda.b #$01
	sta MusicCommand
	
	lda.b #$00
	sta MSU_AUDIO_VOLUME

	sec
	rts
}

scope MSU_Fade: {
	lda RequestedSong
	sta FadeCount
	and #$0F
	sta SNES_MUL_OPERAND_A
	
	lda FadeCount
	and #$F0
	sta FadeCount
	
	lda #$11
	sta SNES_MUL_OPERAND_B
	WaitMulResult()
	
	lda FadeCount
	bne +;
	
	sta FadeStep
	jmp Exit
	
+;
	lda SNES_MUL_DIV_RESULT_L
	sec
	sbc FadeVolume+1
	bcs +;
	eor #$FF
	inc
+;
	sta SNES_DIV_DIVIDEND_L
	lda #$00
	sta SNES_DIV_DIVIDEND_H
	lda FadeCount
	sta SNES_DIV_DIVISOR
	WaitDivResult()
	
	lda SNES_DIV_QUOTIENT_L
	sta FadeTemp+1
	
	lda #$00
	sta SNES_DIV_DIVIDEND_L
	lda SNES_MUL_DIV_RESULT_L
	sta SNES_DIV_DIVIDEND_H
	lda FadeCount
	sta SNES_DIV_DIVISOR
	WaitDivResult()
	
	lda SNES_DIV_QUOTIENT_L
	sta FadeTemp
	bcs +;
	
	rep #$20
	lda FadeTemp
	eor #$FFFF
	inc
	sta FadeTemp
	sep #$20
+;
	rep #$20
	lda FadeTemp
	sta FadeStep
	sep #$20
	lda #$00
	sta FadeVolume
	
	lda #$01
	sta FadeState
Exit:
	rts
}

scope MSU_Stop: {
	lda #$00
	sta MSU_AUDIO_CONTROL
	rts
}

scope Stop_SPC: {
	lda #$F1
	sta SPC_COMM_0
Handshake:
	cmp SPC_COMM_0
	bne Handshake
	
	lda #$00
	sta SPC_COMM_0
	rts
}

// NMI & Reset hijack code
scope Reset_Hijack: {
	lda #$FF
	sta FadeVolume
	sta FadeVolume+1
	lda #$00
	sta FadeState
	
	ldx #$00

hijackLoop:
	lda codeData,x
	sta $0122,x
	inx
	cpx #$04
	bne hijackLoop

	// Original code hijacked
	jml $C10010
	
codeData:
	jml NMI_Update
}

scope NMI_Update: {
	php
	rep #$20
	pha
	
	sep #$20
	
	lda FrameCount
	inc
	sta FrameCount
	
	lda FadeState
	beq Exit
	
	lda FrameCount
	lsr
	bcs Exit
	
	rep #$20
	clc
	lda FadeVolume
	adc FadeStep
	sta FadeVolume
	
	sep #$20
	lda FadeVolume+1
	sta MSU_AUDIO_VOLUME
	
	lda FadeCount
	dec
	bne +;
	
	lda #$00
	sta FadeState
+;
	sta FadeCount
Exit:
	rep #$20
	pla
	plp
	// Call actual NMI code
	jml $000100
}

if (pc() > $CB3FFF) {
	error "Overflow detected"
}