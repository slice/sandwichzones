@ECHO OFF

REM MoonScript compiler.
SET GARRYSMOD=C:\Program Files (x86)\Steam\steamapps\common\GarrysMod
SET MOONPATH=C:\Users\%USERNAME%\Documents\Moon
SET MOONCC=%MOONPATH%\moonc.exe
SET OUTPUT=.\output
set REALOUTPUT=%GARRYSMOD%\garrysmod\addons\sandwichzones

ECHO SandwichZones build process
ECHO - GarrysMod folder: %GARRYSMOD%
ECHO - Moonscript compiler folder: %MOONPATH%
ECHO - Moonc.exe: %MOONCC%
ECHO - Output: %OUTPUT%
ECHO - Real output: %REALOUTPUT%

ECHO Compiling now...

mkdir "%OUTPUT%"
%MOONCC% -t "%OUTPUT%" .\lua\**\*.moon
%MOONCC% -t "%OUTPUT%" .\lua\ulx\modules\sh\ulx_sandwichzones.moon
%MOONCC% -t "%OUTPUT%" .\lua\sandwichzones\properties\*.moon

XCOPY /E /F /Y "%OUTPUT%\*" "%REALOUTPUT%"
