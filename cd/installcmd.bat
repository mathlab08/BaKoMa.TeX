@echo off
color 3e

regedit.exe /s "%~dp0Del_BaKoMaTeX.reg"

@rem Installation of BaKoMa TeX for Windows. Run without arguments to see usage.
   
@rem Version/Revision data 
set VERSION=11.80
set REVISION=181018
set VERSIONINT=1180

@rem Handle location of install.bat and sipmpel check of boot files.
set SCRIPT=%0
set CDROOT=%~d0%~p0
set BASEDIR=%CDROOT%.bakoma
set OS=mswin
@rem echo BaseDir=%BASEDIR%

@rem set BootFiles=( setup.ini Update\ls-R.net bin\win32\setup.exe bin\win32\setupcon.exe bin\win32\setup-noadm.exe bin\win32\setupcom.exe )
set BootFiles=( setupall.ini Update\ls-R.net bin\win32\setup.exe bin\win32\setupcon.exe bin\win32\setup-noadm.exe bin\win32\setupcom.exe )

for %%f in %BootFiles% do (
rem echo Checking %%f
  if not exist "%BASEDIR%\%%f" (
    if not exist "%BASEDIR%\auto\%%f" (
      echo ERROR: Cant find important component "%BASEDIR%[\auto]\%%f"
      exit 1
    )
  )
)

@Rem Parsing user commands ...

set HOME=%USERPROFILE%
set LOCALINST=%HOME%\BaKoMa-TeX-%VERSIONINT%
set SHAREINST=C:\BaKoMa-TeX-%VERSIONINT%

set GUI=No
set GUIOPTS=
set PLOPTS=
set MODE=
set INSTDIR=
set OPTSET=Required
set FULLOPT=.bkz+.all.bkz+.win32.bkz+.win64.bkz

echo ====================================***** Prompt information *****==================================
echo    The command line installer performs the following process: initializes the registry, then 
echo    installs BaKoMa TeX as an administrator, and at the end of the installation a pop-up window 
echo    appears with the message "......Good Luck". At this point, close all other windows that are 
echo    already open, and exit other programs that have been started if possible. Close the network 
echo    and switch the keyboard to English. Finally, click the OK button on the pop-up window to enter 
echo    the registration process. Do not operate the mouse or keyboard and wait about 2 minutes for the 
echo    registration to finish. We wish you success!
echo ====================================================================================================

echo Please enter the path to install BaKoMa TeX (for example, C:\BaKoMa.TeX)
set /p INSTDIR=">"

rem Make sure it's a full installation (default is full installation)
CHOICE /C YN /M "Press Y for full installation. otherwise press N for basic installation"
if errorlevel 2 goto partinstall
if errorlevel 1 goto fullinstall
:fullinstall
SET OPTSET=%FULLOPT%
goto partinstall
:partinstall

set DESKTOP=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\BaKoMa TeX
set PLOPTS=%PLOPTS% -i
set GUIOPTS=%GUIOPTS% -p-i
set GUISETUP=setup.exe

echo Installing version %VERSIONINT% into %INSTDIR%

@if exist %INSTDIR% (
   @echo ERROR Installation folder '%INSTDIR%' is already exists.
   @echo ERROR Remove the folder or choose another folder
   @exit 1
)

mkdir %INSTDIR%

@if NOT exist %INSTDIR% (
   @echo ERROR Cant create installation folder %INSTDIR%.
   @echo ERROR It is probably system do not allow you to create such folder.
   @exit 1
)

@echo Copying boot files into '%INSTDIR%'

for %%f in %BootFiles% do (
rem echo Copying %%f
  @rem echo MkDirForFile: mkdir %INSTDIR%\%%f + rmdir %INSTDIR%\%%f
  mkdir %INSTDIR%\%%f
  rmdir %INSTDIR%\%%f
  if exist "%BASEDIR%\%%f" (
rem echo copy "%BASEDIR%\%%f" "%INSTDIR%\%%f" 
    copy "%BASEDIR%\%%f" "%INSTDIR%\%%f"  >nul 2>nul
  ) else ( 
    if exist "%BASEDIR%\auto\%%f" (
rem echo copy "%BASEDIR%\auto\%%f" "%INSTDIR%\%%f" 
      copy "%BASEDIR%\auto\%%f" "%INSTDIR%\%%f"  >nul 2>nul
    ) else (
      echo ERROR: Cant find important component "%BASEDIR%[\auto]\%%f"
      exit 1
    )
  )
  if "%%f" == "setupall.ini" (
    if exist "%INSTDIR%\%%f" (
rem echo move "%INSTDIR%\%%f" "%INSTDIR%\setup.ini" 
      move "%INSTDIR%\%%f" "%INSTDIR%\setup.ini"   >nul 2>nul
    )
  )
)

@REM Final Stady. Run Setup[|Con|-NoAdm].exe depending on settings.

set INSTBIN=%INSTDIR%\bin\Win32

@if not .%GUI%. == .. (
rem echo "%INSTBIN%\%GUISETUP%" "-S%CDROOT%.bakoma\" -i %OPTSET% %GUIOPTS%
  "%INSTBIN%\%GUISETUP%" "-S%CDROOT%.bakoma\" -i %OPTSET% %GUIOPTS%
) else (
rem echo "%INSTBIN%\setupcon.exe" -i %OPTSET%  "-s%CDROOT%\"  
  "%INSTBIN%\setupcon.exe" -i %OPTSET%  "-s%CDROOT%\" 
  if not exist "%INSTDIR%\SETUP.OK" (
  echo "Sorry, %INSTDIR%\SETUP.OK is absent" 
    exit 1
  )
  @rem Update extension ...
rem echo "%INSTBIN%\PostLine.exe" Setup %PLOPTS%
  "%INSTBIN%\PostLine.exe" Setup %PLOPTS%
)

for %%I in ("%INSTDIR%") do set "drive=%%~dI"
%drive%
cd %INSTDIR%\bin\Win32
setupcom.exe

set "target_file=%INSTDIR%\BaKoMa\Dialog\wxPS\Modal Dialogs\About-AD.wxps"
set "searchA=101 /"
set "replaceA=1018 /"
set "searchB=Unknown"
set "replaceB=%USERNAME%"
set "searchC=102 /"
set "replaceC=1026 /"
set "searchD=EVALUATION"
set "replaceD=SITE"

powershell -Command "(Get-Content '%target_file%') -replace '%searchA%', '%replaceA%' | Set-Content '%target_file%'"  >nul 2>nul
powershell -Command "(Get-Content '%target_file%') -replace '%searchB%', '%replaceB%' | Set-Content '%target_file%'"  >nul 2>nul
powershell -Command "(Get-Content '%target_file%') -replace '%searchC%', '%replaceC%' | Set-Content '%target_file%'"  >nul 2>nul
powershell -Command "(Get-Content '%target_file%') -replace '%searchD%', '%replaceD%' | Set-Content '%target_file%'"  >nul 2>nul

exit 0
