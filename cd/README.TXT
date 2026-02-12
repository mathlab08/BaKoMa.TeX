This CD provides almost complete install of BaKoMa TeX for Windows, MacOS, and Linux.

install.exe - installation programs for Windows (GUI)
install.bat - installetion script for Windows (console)
install.sh  - installation script for Linux and MacOS (console)

There are following installation modes:

   --share (Win/Mac)
	Both Installation and autodownload go to shared area.
   --share (Linux)
	Installation into shared area, but autodownload into HOME folder
   --local
    	Both Installation and autodownload go into HOME folder.

Installed set:

   --full
	Install all material available on CD (1.7 GB required).
   <other>
	Install only most required modules (~150 MB required).
	Missed modules will be autodownload when required.

NOTE: This CD version (unlike to previous) do not include documentation files.
      So, we keep size of ISO inside 400 MB (instead of 1.6 GB as was previous)

NOTE: Documentation may be browsed by using 'BaKoMa MetaHelp' program
      which handle command index for entire document collection
      and autodownload any required documents automatically.

=============================================================================

BaKoMa TeX for Windows may be installed in two variants:

0) Install.exe - provide obvious GUI installation 

1) Shared - installing for all users (adm privelegies are assumed)

	install.bat --share
	
	installation directory:		C:\BaKoMa-TeX-VVVV
	desktop files:			C:\ProgramData\Microsoft\Windows\Start Menu\Programs\BaKoMa TeX

2) Local - installing into local user directory (no required privelegies)

	install.bat --local

	installation directory:		%USERPROFILE%\BaKoMa-TeX-VVVV
	desktop files:			%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\BaKoMa TeX

NOTE: In both cases Autodownload is made into installation folder.

*) Full Install - allows to install all run modules into selected location

	install.bat --share --full

	install.bat --local --full

=============================================================================

BaKoMa TeX for MacOS may be installed in two variants:

1) Shared (Same as old DEB/RPM)
	sudo ./install.sh --share
	installs to:	/Applications/BaKoMa TeX

2) Local (New install into user's folder.)
	./install.sh --local
	installs to:	$HOME/Applications/BaKoMa TeX

NOTE: In both cases Autodownload is made into installation folder.

NOTE: Autodownload/install into local folder may be configured to avoid admin.

=============================================================================

BaKoMa TeX for Linux may be installed in two variants:

1) Shared - installing for all users (adm privs are required)

	sudo ./install.sh --share
	
	installation directory:		/opt/bakoma
	desktop files:			/usr/share/applications
	autodownload packages to:	$HOME/.bakoma/texmf

2) Local - installing into local user directory (no required privelegies)

	./install.sh --local

	installation directory:		$HOME/opt/bakoma
	desktop files:			$HOME/.local/share/applications
	autodownload packages to:	$HOME/opt/bakoma/texmf

=============================================================================
