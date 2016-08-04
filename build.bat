@ECHO OFF

REM MoonScript compiler.
SET MOONPATH=C:\Users\cheesy\Documents\Moon
SET MOONCC=%MOONPATH%\moonc.exe
SET OUTPUT=.\output
set REALOUTPUT=C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons\sandwichzones

mkdir "%OUTPUT%"
%MOONCC% -t "%OUTPUT%" .\lua\**\*.moon
%MOONCC% -t "%OUTPUT%" .\lua\ulx\modules\sh\ulx_sandwichzones.moon
%MOONCC% -t "%OUTPUT%" .\lua\sandwichzones\properties\*.moon

XCOPY /E /F /Y "%OUTPUT%\*" "%REALOUTPUT%"
