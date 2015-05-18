Secret of Mana (U) MSU-1
Version 1.0
by DarkShock

This hack adds CD quality audio to Secret of Mana (U) using the MSU-1 chip invented by byuu.
The hack has been tested on SD2SNES, BSNES 075 and higan 094. The patched ROM needs to be named som_msu1.sfc.

===============
= Using BSNES =
===============
1. Patch the ROM
2. Generate the .pcm
3. Launch the game

===============
= Using higan =
===============
1. Patch the ROM
2. Launch it using higan
3. Go to %USERPROFILE%\Emulation\Super Famicom\topgear2s_msu1.sfc in Windows Explorer.
4. Copy manifest.bml and the .pcm file there
5. Run the game

====================
= Using on SD2SNES =
====================
Drop the ROM file, topgear2_msu1.msu and the .pcm files in any folder. (I really suggest creating a folder)
Launch the game and voilà, enjoy !

===========
= Credits =
===========
* DarkShock - ASM hacking & coding, Music editing
* David Thomas /GinBunBun - Music compilation

=========
= Music =
=========
$00 / 00 = Secret of the Arid Sands
$01 / 01 = Flight into the Unknown
$02 / 02 = Star of Darkness
$03 / 03 = Prophecy
$04 / 04 = Danger
$05 / 05 = Far Thunder
$06 / 06 = The Wind Nevere Ceases
$07 / 07 = Close your Eyelids
$08 / 08 = Spirit of the Night
$09 / 09 = The Fairy Child
$0A / 10 = What the Forest Taught Me
$0B / 11 = Eternal Recurrence
$0C / 12 = Oracle
$0D / 13 = Tell a Strange Tale
$0E / 14 = Into the tick of it
$0F / 15 = Rose and Ghost
$10 / 16 = Did you See the Sea?
$11 / 17 = The Color of the Summer Sky
$12 / 18 = Menu music
$13 / 19 = The Legend
$14 / 20 = The Orphan of Storm
$15 / 21 = Eight Ringing Bells
$16 / 22 = Dancing Beasts
$17 / 23 = Victory !
$18 / 24 = Got Mana Sword SFX
$19 / 25 = Cannon Travel Lunch (SFX)
$1A / 26 = Cannon Travel (SFX)
$1B / 27 = Ceremony
$1C / 28 = Always Together / Together Always
$1D / 29 = A Prayer and a Whisper
$1E / 30 = New Contient Rises (SFX)
$1F / 31 = Happenings on a Moonlight Night
$20 / 32 = A Curious Happening
$21 / 33 = ?????
$22 / 34 = Midge Mallet (SFX)
$23 / 35 = Unknown Jingle
$24 / 36 = A Wish
$25 / 37 = Monarch on the Shore
$26 / 38 = Steel and Traps
$27 / 39 = Pure Night
$28 / 40 = Flammie Coming (SFX)
$29 / 41 = Kind Memories
$2A / 42 = The Holy Intruder
$2B / 43 = In the Darkness' Depths (The Dead of Night)
$2C / 44 = Angel's Fear
$2D / 45 = Squaresoft rowing sound
$2E / 46 = (Jingle)
$2F / 47 = (Jingle)
$30 / 48 = (Jingle)
$31 / 49 = Give Love its Rightful Time
$32 / 50 = The Second Truth from the left
$33 / 51 = The Curse
$34 / 52 = I Won't Forget
$35 / 53 = Ally Joins (Jingle)
$36 / 54 = To Reach Tomorrow
$37 / 55 = One of them is hope
$38 / 56 = A Conclusion
$39 / 57 = Meridian Dance
$3A / 58 = The Wings No Longer Beat

=============
= Compiling =
=============
Source is availabe on GitHub: https://github.com/mlarouche/SecretOfMana-MSU1

To compile the hack you need

* bass v14 (https://web.archive.org/web/20140710190910/http://byuu.org/files/bass_v14.tar.xz)
* wav2msu (https://github.com/mlarouche/wav2msu)

To distribute the hack you need

* uCON64 (http://ucon64.sourceforge.net/)
* 7-Zip (http://www.7-zip.org/)

make.bat assemble the patch
create_pcm.bat create the .pcm from the WAV files
distribute.bat distribute the patch
make_all.bat does everything
