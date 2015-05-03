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

// Constants
if {defined EMULATOR_VOLUME} {
	constant FULL_VOLUME($60)
} else {
	constant FULL_VOLUME($FF)
}

// Game variables
variable MusicCommand($1E00)
variable RequestedSong($1E01)
variable PreviousSong($1E05)

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

// JSL to $C30004 found via hex editor
seek($C00FDC)
	jsl MSU_Main
seek($C029F7)
	jsl MSU_Main
seek($C0399F)
	jsl MSU_Main
// This one make the game crash when you hurt a Rabite
//seek($C04170)
//	jsl MSU_Main
seek($C08154)
	jsl MSU_Main
seek($C08CF3)
	jsl MSU_Main
seek($C0B586)
	jsl MSU_Main
seek($C137A5)
	jsl MSU_Main
seek($C1D4FD)
	jsl MSU_Main
seek($C1DAD5)
	jsl MSU_Main
seek($C1F109)
	jsl MSU_Main
seek($C230DC)
	jsl MSU_Main
seek($C230F8)
	jsl MSU_Main
seek($C23103)
	jsl MSU_Main
seek($C23116)
	jsl MSU_Main
seek($C2A93E)
	jsl MSU_Main
seek($C640D2)
	jsl MSU_Main
seek($C79B3E)
	jsl MSU_Main
	// This one crashes at start, compressed data
//seek($C7B0FE)
//	jsl MSU_Main
seek($D0CEF1)
	jsl MSU_Main

// MSU code
seek($C8FEE0)
scope MSU_Main: {
	php
	rep #$30
	pha
	phx
	phy
	
	sep #$20
	CheckMSUPresence(OriginalCode)
	
	lda.w MusicCommand
	beq DoNothing
	
	cmp #$80
	beq DoFade
	cmp #$01
	bne OriginalCode
	
	// The original code clears the music command after reading it
	stz MusicCommand
	
	// Check if the song is already playing
	xba
	lda $1E02
	and #$0F
	pha
	lda.w RequestedSong
	pha
	plx
	cpx PreviousSong
	beq DoNothing
	
	// Set MSU-1 track
	lda.w RequestedSong
	sta MSU_AUDIO_TRACK_LO
	
	// Set previous song for game
	sta.w PreviousSong
	lda $1E02
	and #$0F
	sta $1E06
	lda $1E03
	sta $1E07
	
	lda.b #$00
	sta MSU_AUDIO_TRACK_HI
	
CheckMSUAudioStatus:
	lda MSU_STATUS
	and.b #MSU_STATUS_AUDIO_BUSY
	bne CheckMSUAudioStatus
	
	// Check if the track is missing
	lda MSU_STATUS
	and.b #MSU_STATUS_TRACK_MISSING
	bne OriginalCode
	
	// Play the song and add repeat if needed
	//jsr TrackNeedLooping
	lda #$03
	sta MSU_AUDIO_CONTROL
	
	// Set volume
	lda.b #FULL_VOLUME
	sta MSU_AUDIO_VOLUME
	
	jmp DoNothing
	
OriginalCode:
	rep #$30
	ply
	plx
	pla
	plp
	jml $C30004
	
DoNothing:
	rep #$30
	ply
	plx
	pla
	plp
	rtl
	
DoFade:
	// TODO: Do actual fade
	lda.w RequestedSong
	cmp #$8F
	bne FadeOut
	
	// "Fade-in"
	lda #$03
	sta MSU_AUDIO_CONTROL
	bra ExitFade
	
FadeOut:
	// "Fade-out"
	lda #$00
	sta MSU_AUDIO_CONTROL
ExitFade:
	jmp DoNothing
}

if (pc() > $C8FFFF) {
	error "Overflow detected"
}