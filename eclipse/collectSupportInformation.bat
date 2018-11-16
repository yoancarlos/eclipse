@echo off

:: set path to eclipse folder
if exist "plugins" (
  :: we are called top-level
  set ECLIPSEHOME=.
)
if exist "../../plugins" (
  :: we are called inside bundle dir through the symlink
  set ECLIPSEHOME=..\..
)

:: Find .ini file to determine the executable name
for /f "delims= tokens=1" %%i in ('dir /B /OD %ECLIPSEHOME%\*.ini') do set ECLIPSEINI=%%~ni

:: Start eclipse with the Standalone Information Collector application
echo Collecting support information using %ECLIPSEHOME%\%ECLIPSEINI%.exe. Please be patient...

%ECLIPSEHOME%\%ECLIPSEINI%.exe -application com.sap.ide.support.StandaloneInformationCollector -data @none
