@ECHO OFF
del som_msu1.sfc

copy som_original.sfc som_msu1.sfc

set BASS_ARG=
if "%~1" == "emu" set BASS_ARG=-d EMULATOR_VOLUME

bass %BASS_ARG% -o som_msu1.sfc secret_of_mana_msu1.asm
