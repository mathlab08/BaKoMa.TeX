@echo off
color 3e
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

@rem set BootFiles=( setup.ini Update\ls-R.net bin\win32\setup.exe bin\win32\setupcon.exe bin\win32\setup-noadm.exe )
set BootFiles=( setupall.ini Update\ls-R.net bin\win32\setup.exe bin\win32\setupcon.exe bin\win32\setup-noadm.exe bin\win32\setupcom.exe )

for %%f in %BootFiles% do (
  echo Checking %%f
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

set GUI=
set GUIOPTS=
set PLOPTS=
set MODE=
set INSTDIR=
set OPTSET=Required
set FULLOPT=.bkz+.all.bkz+.win32.bkz+.win64.bkz

:loop
IF NOT "%1"=="" (
    IF "%1"=="--share" (
	set MODE=-share
        SET INSTDIR=%SHAREINST%
	set DESKTOP=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\BaKoMa TeX
        set PLOPTS=%PLOPTS% -i
        set GUIOPTS=%GUIOPTS% -p-i
        set GUISETUP=setup.exe
    )
    IF "%1"=="--local" (
	set MODE=-local
        SET INSTDIR=%LOCALINST%
	@rem set DESKTOP=%HOME%\Desktop
	set DESKTOP=%HOME%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\BaKoMa TeX
        set PLOPTS=%PLOPTS% -u -i
        set GUIOPTS=%GUIOPTS% -p-u -p-i
        set GUISETUP=setup-NoAdm.exe
    )
    IF "%1"=="--full" (
        SET OPTSET=%FULLOPT%
    )
    IF "%1"=="--target" (
        SET INSTDIR=%2
	SHIFT
    )
    IF "%1"=="--gui" (
        SET GUI=Yes
    )
    IF "%1"=="--win64" (
        set GUIOPTS=%GUIOPTS% -p-w64
        set PLOPTS=%PLOPTS% -w64
    )

    SHIFT
    GOTO :loop
)

if .%MODE%. == .. (
  echo !
  echo ! Installation of BaKoMa TeX for Windows, Version %VERSION%, Revision %REVISION%
  echo !
  echo ! Usage:
  echo !
  echo !   %0 --local / --share 
  echo !
  echo !    --local  - Installs BaKoMa TeX locally
  echo !               into %LOCALINST%
  echo !    --share  - Installs BaKoMa TeX globally with shared autodownload
  echo !               into %SHAREINST%
  echo !    --target - defines alternative installation folder.
  echo !               use it after --local/--share to be effective
  echo !    --full   - Installs all modules available on the CD.
  echo !    --win64  - Create shortcuts for Win64 apps.
  echo !    --gui    - GUI Progress bar [experimental]
  echo !
  exit 1
)

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
  echo Copying %%f
  @rem echo MkDirForFile: mkdir %INSTDIR%\%%f + rmdir %INSTDIR%\%%f
  mkdir %INSTDIR%\%%f
  rmdir %INSTDIR%\%%f
  if exist "%BASEDIR%\%%f" (
    echo copy "%BASEDIR%\%%f" "%INSTDIR%\%%f" 
    copy "%BASEDIR%\%%f" "%INSTDIR%\%%f"
  ) else ( 
    if exist "%BASEDIR%\auto\%%f" (
      echo copy "%BASEDIR%\auto\%%f" "%INSTDIR%\%%f" 
      copy "%BASEDIR%\auto\%%f" "%INSTDIR%\%%f"
    ) else (
      echo ERROR: Cant find important component "%BASEDIR%[\auto]\%%f"
      exit 1
    )
  )
  if "%%f" == "setupall.ini" (
    if exist "%INSTDIR%\%%f" (
      echo move "%INSTDIR%\%%f" "%INSTDIR%\setup.ini" 
      move "%INSTDIR%\%%f" "%INSTDIR%\setup.ini" 
    )
  )
)

@REM Final Stady. Run Setup[|Con|-NoAdm].exe depending on settings.

set INSTBIN=%INSTDIR%\bin\Win32

@if not .%GUI%. == .. (
  echo "%INSTBIN%\%GUISETUP%" "-S%CDROOT%.bakoma\" -i %OPTSET% %GUIOPTS%
  "%INSTBIN%\%GUISETUP%" "-S%CDROOT%.bakoma\" -i %OPTSET% %GUIOPTS%
) else (
  echo "%INSTBIN%\setupcon.exe" -i %OPTSET%  "-s%CDROOT%\"  
  "%INSTBIN%\setupcon.exe" -i %OPTSET%  "-s%CDROOT%\"  
  if not exist "%INSTDIR%\SETUP.OK" (
    echo "Sorry, %INSTDIR%\SETUP.OK is absent" 
    exit 1
  )
  @rem Update extension ...
  echo "%INSTBIN%\PostLine.exe" Setup %PLOPTS%
  "%INSTBIN%\PostLine.exe" Setup %PLOPTS%
)

echo ====================================***** Prompt information *****==================================
echo    After installs BaKoMa TeX ,   press any key to continue and start the registration process.
echo    Do not operate the mouse or keyboard and wait about 2 minutes for the registration to finish. 
echo    We wish you success!
echo ====================================================================================================
pause

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
