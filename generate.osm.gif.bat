@set osmconvert=binaries\osmconvert.exe
@set maperitive=binaries\Maperitive\Maperitive.Console.exe
@set imconvert=binaries\ImageMagick\convert.exe
@set wget=binaries\wget.exe

@set skip_pbf_update=1
@set skip_maperitive=1

@del %png_folder%\*.png

%wget% -nc http://be.gis-lab.info/data/osm_dump/dump/UA/%initial_pbf%
@if not exist %initial_pbf% @echo %initial_pbf% not found
@if not exist %initial_pbf% goto :eof
%osmconvert% %initial_pbf% %boundary% -o=tmp.pbf
@call :Maperitive %initial_pbf%

@for /F "tokens=*" %%a in ('dir %osc_folder%\*.o5c /O:N /b') do @(@call :processOsc %%a)

@del tmp.pbf

@if     exist %png_folder%\%initial_pbf%.png %imconvert% -delay %gif_delay% -loop 0 %png_folder%\%initial_pbf%.png %png_folder%\*o5c.png %result_file%
@if not exist %png_folder%\%initial_pbf%.png %imconvert% -delay %gif_delay% -loop 0 %png_folder%\*o5c.png %result_file%

@goto :eof

:processOsc
@set osc_file=%1
@if %osc_file% equ %start_update% set skip_pbf_update=0
@if %skip_pbf_update% equ 1 @goto :eof

%osmconvert% tmp.pbf %osc_folder%\%1 -o=new_tmp.pbf
@if "%boundary%" neq "" %osmconvert% new_tmp.pbf %boundary% -o=new_b_tmp.pbf
@if "%boundary%" equ "" copy new_tmp.pbf new_b_tmp.pbf
@del tmp.pbf
@del new_tmp.pbf
@rename new_b_tmp.pbf tmp.pbf

@call :Maperitive %1

@if %osc_file% equ %stop_processing% set skip_pbf_update=1
@goto :eof

:Maperitive
@if %1 equ %start_maperitive% set skip_maperitive=0
@if %skip_maperitive% equ 1 @goto :eof

@echo use-ruleset alias=default > Maperitive_%1.scr
@echo load-source "%cd%\tmp.pbf" >> Maperitive_%1.scr
@echo move-pos x=%x% y=%y% >> Maperitive_%1.scr
@echo export-bitmap width=%width% height=%height% zoom=%zoom% file=%cd%\%png_folder%\%1.png >> Maperitive_%1.scr
%maperitive% %cd%\Maperitive_%1.scr
@del Maperitive_%1.scr
@del %png_folder%\*.georef
%imconvert% %png_folder%\%1.png -gravity South -annotate 0 %1 %png_folder%\%1.png
@goto :eof