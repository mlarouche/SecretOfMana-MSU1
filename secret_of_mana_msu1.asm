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
variable MusicCommand($7E1E00)
variable RequestedSong($7E1E01)
variable PreviousSong($7E1E05)

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
seek($C8FEE0)
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
	
	cmp #$80
	beq DoFade
	cmp #$01
	bne OriginalCode
	
	// The original code clears the music command after reading it
	stz MusicCommand
	
	// Check if the song is already playing
	xba
	lda $7E1E02
	and #$0F
	pha
	lda RequestedSong
	pha
	plx
	cpx PreviousSong
	beq DoNothing
	
	// Set MSU-1 track
	lda RequestedSong
	sta MSU_AUDIO_TRACK_LO
	lda.b #$00
	sta MSU_AUDIO_TRACK_HI
	
CheckMSUAudioStatus:
	lda MSU_STATUS
	and.b #MSU_STATUS_AUDIO_BUSY
	bne CheckMSUAudioStatus
	
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
	
	// Set previous song for game
	lda RequestedSong
	sta PreviousSong
	lda $7E1E02
	and #$0F
	sta $7E1E06
	lda $7E1E03
	sta $7E1E07
	
	jmp DoNothing
	
TrackMissing:
	lda.b #$01
	sta MusicCommand
	
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
	
DoFade:
	// TODO: Do actual fade
	lda RequestedSong
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