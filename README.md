# target_ph

About: target_ph generates prescription files (.tif) for variable rate liming based on a combination of national data (dsms) and local data. The code is intended for implementation in decision support systems for precision agriculture. it is developed for Swedish conditions. The following text is in Swedish.

(in Swedish)
Upplägg just nu:
I filen scripts\1_settings.r görs alla ändringar (sökvägar, parametrar etc). Övriga skript ska aldrig behöva öppnas utan körs från detta huvudskript. R-paket som behövs men inte finns installerade kommer att installeras och en mapp kommer skapas under ”working directory” dit utdata exporteras.

Gör så här: 
Ändra till egna settings (sökvägar, parametrar et c) i filen scripts\1_settings.r och ör hela skriptet.
