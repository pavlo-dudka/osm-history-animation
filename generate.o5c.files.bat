@set source_folder=%1
@set target_folder=%2
@set frequency=%3
md %target_folder%

@for /F "tokens=*" %%a in ('dir %source_folder%\ua-*.* /O:N /b') do @(@call :processOsc %%a)
@goto :eof

:processOsc
@set osc_file=%1
@if %frequency% equ day @set new_file=%target_folder%\%osc_file:~0,9%.o5c
@if %frequency% equ 10days @set new_file=%target_folder%\%osc_file:~0,8%.o5c
@if %frequency% equ month @set new_file=%target_folder%\%osc_file:~0,7%.o5c
@if %frequency% equ year @set new_file=%target_folder%\%osc_file:~0,5%.o5c
@if "%new_file%" equ "" @goto :eof
@if     exist %new_file% @echo Merging    %osc_file% to %new_file%
@if not exist %new_file% @echo Converting %osc_file% to %new_file%
@if     exist %new_file% binaries\osmconvert.exe %new_file% %source_folder%\%osc_file% -o=new.o5c --out-o5c
@if not exist %new_file% binaries\osmconvert.exe %source_folder%\%osc_file% -o=new.o5c --out-o5c
@if     exist %new_file% @del %new_file%
@move new.o5c %new_file% >nul
@goto :eof