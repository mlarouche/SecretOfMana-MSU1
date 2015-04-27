@ECHO OFF

del /q SecretOfMana_MSU1.zip
del /q SecretOfMana_MSU1_Music.7z

mkdir SecretOfMana_MSU1
ucon64 -q --snes --chk som_msu1.sfc
ucon64 -q --mki=topgear2_original.sfc som_msu1.sfc
copy som_msu1.ips SecretOfMana_MSU1
copy README.txt SecretOfMana_MSU1
copy som_msu1.msu SecretOfMana_MSU1
copy som_msu1.xml SecretOfMana_MSU1
copy manifest.bml SecretOfMana_MSU1
"C:\Program Files\7-Zip\7z" a -r SecretOfMana_MSU1.zip SecretOfMana_MSU1

"C:\Program Files\7-Zip\7z" a SecretOfMana_MSU1_Music.7z *.pcm

del /q som_msu1.ips
rmdir /s /q SecretOfMana_MSU1