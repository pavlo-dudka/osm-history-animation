@set osmconvert=binaries\osmconvert.exe
@set maperitive=binaries\Maperitive\Maperitive.Console.exe
@set imconvert=binaries\ImageMagick\convert.exe
@set wget=binaries\wget.exe

@set osm_dump_url=http://be.gis-lab.info/data/osm_dump
@set osm_diff_url=http://be.gis-lab.info/data/osm_dump/diff/UA
@set osc_folder=be.gis-lab.info\data\osm_dump\diff\UA
@set initial_pbf=UA-140821.osm.pbf

@set boundary=-b=33.377623558044434,49.05553269995769,33.44929218292236,49.08491316820349
@set width=1275
@set height=1050
@set zoom=15

%wget% -nc %osm_dump_url%/dump/UA/%initial_pbf%
if not exist %initial_pbf% goto :eof
%osmconvert% %initial_pbf% %boundary% --complex-ways -o=UA.osm
@call :Maperitive %initial_pbf%

%wget% -q -r -nc -np -l 1 -A gz %osm_diff_url%
@set skip_current_osc=1
@for /F "tokens=*" %%a in ('dir %osc_folder%\*.gz /O:N /b') do @(@call :processOsc %%a)

@del UA.osm

%imconvert% -delay 100 -loop 0 png\%initial_pbf%.png png\*osc.gz.png result.gif

@goto :eof

:processOsc
@set osc_file=%1
@if %osc_file:~0,9% equ %initial_pbf:~0,9% set skip_current_osc=0
@if %skip_current_osc% equ 1 @goto :eof
%osmconvert% UA.osm %osc_folder%\%1 %boundary% --complex-ways -o=UA_new.osm
@del UA.osm
@rename UA_new.osm UA.osm
@call :Maperitive %1
@goto :eof

:Maperitive
@echo use-ruleset alias=default > Maperitive.scr
@echo load-source "%cd%\UA.osm" >> Maperitive.scr
@echo export-bitmap width=%width% height=%height% zoom=%zoom% file=%cd%\png\%1.png >> Maperitive.scr
%maperitive% %cd%\Maperitive.scr
@del Maperitive.scr
@del png\*.georef
%imconvert% png\%1.png -gravity South -annotate 0 %1 png\%1.png
@goto :eof