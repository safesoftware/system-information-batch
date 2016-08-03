:: system_information.bat
:: Should be on the Floating and Fixed troubleshooting pages on FMEPedia
:: as well as on the General Troubleshooting
:: Created by Ryan Cragg
:: Contents Edited by De Wet van Niekerk
:: Last edited on 2014-09-24
:: Contents Edited by Brian Pont
:: Last edited on 2015-10-27

:: We turn echo off so that the screen doesn't show each command as it is run
	@ECHO OFF

:: The following line is necessary for ERRORLEVEL capture.
	SetLocal EnableDelayedExpansion
	
:: This batch file must be run from the directory it is placed in
:: but if it is run in Admin mode, it will sometimes run from \windows\system32
:: We can set it to run from the current folder using pushd %~dp0

	pushd %~dp0

	


::We use REPORT_FILE to make it easier to rename the output at a later date.
	set REPORT_FILE="%CD%\FMEReport.html"
	del %REPORT_FILE%

:: cls clears the screen, just to keep things tidy.  We give it a nice colour too
	cls
::I set the colour just to make it grab the users attention.
	color c0

:: Let's inform the customer about what is about to happen
	ECHO ***Important! ***
	echo.
	ECHO This batch file should be run using "Run as Administrator"
	echo.
	ECHO If you just double-clicked it, run it again by right-clicking on it
	ECHO and selecting "Run as Administrator"
	echo.
	ECHO Press CTRL-C to Quit, or
	pause	

:: Now for a nicer colour	
	color 0f
	cls

:: Let's reassure the customer that something is actually happening
	echo Gathering Information and saving it into:
	echo %REPORT_FILE%
	echo.
	echo This may take several minutes...
	echo.

:: Output the HTML header section, including TOC
echo. >> %REPORT_FILE%
call:htmlHeader

:: It might be useful to know where this batch file was run from
	echo system_information.bat was run from %CD% at >> %REPORT_FILE%
  date /T >> %REPORT_FILE%
  time /T >> %REPORT_FILE%
	echo.  >> %REPORT_FILE%

	
:: Now, let's get the system information
echo.  >> %REPORT_FILE%

call:htmlSectionHeader sysinfo "System Information"

echo   Take note of:  >> %REPORT_FILE%
echo ^<ul^> >> %REPORT_FILE%
echo ^<li^>Volume ID (If changing over time, the Registration Key will change)  ^</li^> >> %REPORT_FILE%
echo ^<li^>OS Name  ^</li^> >> %REPORT_FILE%
echo ^<li^>OS Version  ^</li^> >> %REPORT_FILE%
echo ^<li^>System Model  ^</li^> >> %REPORT_FILE%
echo ^<li^>System Type  ^</li^> >> %REPORT_FILE%
echo ^<li^>Available Physical Memory^</li^>  >> %REPORT_FILE%
echo ^<li^>Graphics Card^</li^>  >> %REPORT_FILE%
echo ^</ul^> >> %REPORT_FILE%
echo.  >> %REPORT_FILE%
	
	echo ^<pre^> >> %REPORT_FILE%

:: This command grabs the system information
:: It might not work on XP
	vol >> %REPORT_FILE%
	systeminfo  >> %REPORT_FILE%
	echo.  >> %REPORT_FILE%
    wmic os get OSArchiteccture >> %REPORT_FILE%
	echo. >> %REPORT_FILE%
	wmic path win32_VideoController get name >> %REPORT_FILE%
	echo. >> %REPORT_FILE%
	echo ^</pre^> >> %REPORT_FILE%

call:htmlSectionFooter

call:htmlSectionHeader processes "Running Processes"
echo.  >> %REPORT_FILE%
echo Here is an edited list of what is running ^<br /^> >> %REPORT_FILE%
echo   Take note of:^<br /^>  >> %REPORT_FILE%
echo		^<blockquote^>Anything with FME in the name^<br /^>  >> %REPORT_FILE%
echo		safe.exe^<br /^>  >> %REPORT_FILE%
echo		lmgrd.exe ^<br /^> >> %REPORT_FILE%
echo		Executables with other company names.  Might be vendor deamons.  ^</blockquote^> >> %REPORT_FILE%
echo.  >> %REPORT_FILE%
:: Tell the customer what we are doing
	echo Scanning running tasks...
:: This grabs the shortened task list
	echo ^<pre^> >> %REPORT_FILE%
	tasklist /FI "IMAGENAME ne System Idle Process" /FI "IMAGENAME ne System" /FI "IMAGENAME ne smss.exe" /FI "IMAGENAME ne csrss.exe" /FI "IMAGENAME ne wininit.exe" /FI "IMAGENAME ne winlogon.exe" /FI "IMAGENAME ne services.exe" /FI "IMAGENAME ne lsass.exe" /FI "IMAGENAME ne lsm.exe" /FI "IMAGENAME ne svchost.exe" /FI "IMAGENAME ne LogonUI.exe" /FI "IMAGENAME ne SLsvc.exe" /FI "IMAGENAME ne spoolsv.exe" /FI "IMAGENAME ne taskeng.exe" /FI "IMAGENAME ne logon.scr" /FI "IMAGENAME ne winlogon.exe" /FI "IMAGENAME ne explorer.exe" /FI "IMAGENAME ne tasklist.exe" >> %REPORT_FILE%
	echo ^</pre^> >> %REPORT_FILE%
	call:htmlSectionFooter

	call:htmlSectionHeader envvar "Environment Variables"
:: Next, let's check the path, and all other environment variables:
echo 	Take note of: ^<br /^> >> %REPORT_FILE%
echo 		^<blockquote^>LM_LICENSE_FILE (shouldn't exist) ^<br /^> >> %REPORT_FILE%
echo 		SAFE_LICENSE_FILE (shouldn't exist)^<br /^> >> %REPORT_FILE%
echo 		ARCGIS_LICENSE_FILE (might exist, make sure it is correct)^<br /^>  >> %REPORT_FILE%
echo 		PATH ^</blockquote^> >> %REPORT_FILE%


:: Tell the customer what we are doing
	echo Saving Environment Variables...

:: Check to see if LM_LICENSE_FILE or SAFE_LICENSE_FILE exist.
:: They shouldn't.  Note the !'s used in the IF statement.
	echo ^<pre^> >> %REPORT_FILE%
	SET LM_CHECK=LM_LICENSE_FILE;SAFE_LICENSE_FILE;FME_LMGRD_PATH;FME_LMUTIL_PATH;SAFE_LOG_PATH
	FOR %%c IN (%LM_CHECK%) DO (
		IF DEFINED %%c (
			echo *** >> %REPORT_FILE%
			echo *** >> %REPORT_FILE%
			echo *** >> %REPORT_FILE%
			echo OH NO, BADNEWS >> %REPORT_FILE%
			echo %%c exists >> %REPORT_FILE%
			echo This MIGHT be a bad thing.  It MIGHT work now, but will probably break in the future. >> %REPORT_FILE%
			echo %%c is set to !%%c! >> %REPORT_FILE%
			echo *** >> %REPORT_FILE%
			echo *** >> %REPORT_FILE%
			echo *** >> %REPORT_FILE%
			echo. >> %REPORT_FILE%
		) ElSE echo %%c is not defined. >> %REPORT_FILE%
	)
echo ***************************************************************************  >> %REPORT_FILE%
echo.  >> %REPORT_FILE%

:: Better remove LM_CHECK, so it doesn't get reported.	
	SET LM_CHECK=
	
:: This command grabs all of the environment variables
	set >> %REPORT_FILE%
	echo ^</pre^> >> %REPORT_FILE%
	
	call:htmlSectionFooter
	
	call:htmlSectionHeader sdelib "SDE Libraries"
echo Check to see if SDE libaries exist.>> %REPORT_FILE%	
echo 	If they exist, sde.dll, sg.dll, and pe.dll will be listed below. >> %REPORT_FILE%	
echo.  >> %REPORT_FILE%

:: Check to see if sde.dll, sg.dll, and pe.dll are in the ArcGIS\bin\ folder
:: If those libraries exist, the SDE30 format should work
	echo ^<pre^> >> %REPORT_FILE%
	SET SDEPath=AGSSERVERJAVA;AGSENGINEJAVA;AGSDESKTOPJAVA;AGSDEVKITJAVA;ARCGISHOME;ARCHOME;SDEHOME;AGSSERVER;AGSDESKTOP
	FOR %%b IN (%SDEPath%) DO (
		IF DEFINED %%b (
			echo *** >> %REPORT_FILE%
			echo The SDE Libraries Exist >> %REPORT_FILE%
			echo The location is stored in %%b >> %REPORT_FILE%
			echo *** >> %REPORT_FILE%
			echo. >> %REPORT_FILE%
			echo 32-bit libraries >> %REPORT_FILE%
		    echo ***************************************************************************  >> %REPORT_FILE%
			echo. >> %REPORT_FILE%
			dir "!%%b!\bin\sde.dll" "!%%b!\bin\sg.dll" "!%%b!\bin\pe.dll"  >> %REPORT_FILE%
			echo. >> %REPORT_FILE%
			echo 64-bit libraries >> %REPORT_FILE%
			echo ***************************************************************************  >> %REPORT_FILE%
			echo. >> %REPORT_FILE%
			dir "!%%b!\bin64\sde.dll" "!%%b!\bin64\sg.dll" "!%%b!\bin64\pe.dll" >> %REPORT_FILE%
			echo. >> %REPORT_FILE%
		)
	)
	echo ^</pre^> >> %REPORT_FILE%
	
	call:htmlSectionFooter
	call:htmlSectionHeader oractns "Oracle"
	
echo Check to see if Oracle's ORACLE_HOME OR TNS_ADMIN is set,				>> %REPORT_FILE%
echo and if tnsnames.ora and oci.dll files exist.					>> %REPORT_FILE%
echo It is permissible to install both 32 and 64 bit clients together; >> %REPORT_FILE%
echo for FME purposes you just have to make sure that ORACLE_HOME is *not* defined, >> %REPORT_FILE%
echo and that the PATH includes both instant clients' installation directories (in either order). ^<br /^> >> %REPORT_FILE%	
echo If ORACLE_HOME OR TNS_ADMIN exist, they will be listed below >> %REPORT_FILE%	
echo.  >> %REPORT_FILE%

:: Check to see if Check to see if Oracle's ORACLE_HOME;TNS_ADMIN, and then find if tnsnames.ora and oci.dll files exist.
	echo ^<pre^> >> %REPORT_FILE%
	SET ORACLE_CHECK=ORACLE_HOME;TNS_ADMIN
	FOR %%c IN (%ORACLE_CHECK%) DO (
		IF DEFINED %%c (
			echo *** >> %REPORT_FILE%
			echo OH, this could be good or bad: >> %REPORT_FILE%
			echo %%c exists >> %REPORT_FILE%
			echo %%c is set to !%%c! >> %REPORT_FILE%
			echo The contents of !%%c!\Network\Admin\TNSNAMES.ORA is: >> %REPORT_FILE%
			type "!%%c!\Network\Admin\TNSNAMES.ORA" >> %REPORT_FILE%
			echo *** >> %REPORT_FILE%
			echo. >> %REPORT_FILE%
		) ElSE echo %%c is not defined as an environment variable. >> %REPORT_FILE%
	)

	
:: These first two lines parse the PATH variable.  We then search each folder in the path for oci.dll.
	SET TempPath="%Path:;=";"%"
	FOR %%a IN (%TempPath%) DO (
		for %%F in ("%%~a\oci.dll*") do (
			echo ***************************************************************************  >> %REPORT_FILE%
			dir "%%F"  >> %REPORT_FILE%
			echo ***************************************************************************  >> %REPORT_FILE%
			echo.  >> %REPORT_FILE%
		)
	)
	echo ^</pre^> >> %REPORT_FILE%
	
echo Here are the contents of ORACLE_HOME as defined in the registry, and  >> %REPORT_FILE%
echo listings of tnsnames.ora files as found.  Unfortunately, there is no >> %REPORT_FILE%
echo built-in way to check whether dll's are 32-bit or 64-bit. There are >> %REPORT_FILE%
echo tools that do it, but they must be installed. >> %REPORT_FILE%
	
	echo ^<pre^> >> %REPORT_FILE%


	FOR /f "tokens=3" %%O IN ('reg query "hklm\software\ORACLE" /f "ORACLE_HOME" /s /e ^| findstr REG_SZ') do (
		rem call:dirContents %%O
		call:fileContents %%O\network\admin\tnsnames.ora
	)

	FOR /f "tokens=3" %%O IN ('reg query "hklm\software\wow6432node\ORACLE" /f "ORACLE_HOME" /s /e ^| findstr REG_SZ') do (
		rem call:dirContents %%O
		call:fileContents %%O\network\admin\tnsnames.ora
	)
	echo ^</pre^> >> %REPORT_FILE%

	call:htmlSectionFooter
  
	call:htmlSectionHeader autodesk "Autodesk"

echo Contents of the Autodesk plugin directories: >> %REPORT_FILE%

  echo ^<pre^> >> %REPORT_FILE%
    
    call:dirContents %APPDATA%\Autodesk\Revit\Addins
    call:dirContents %APPDATA%\Autodesk\ApplicationPlugins
  
  echo ^</pre^> >> %REPORT_FILE%

  
  
  call:htmlSectionFooter
    
	call:htmlSectionHeader registry Registry
	
echo 	Take Note of:  ^<br /^> >> %REPORT_FILE%
echo		^<ul^>^<li^>Anything with License in the name if you have an old FME.^</li^>  >> %REPORT_FILE%
echo		^<li^>"BUILD" will list what FME builds have been installed.^</li^>  >> %REPORT_FILE%
echo		^<li^>"Extensions" will list what FME build extended what extension.^</li^>  >> %REPORT_FILE%
echo		^<li^>Check the ArcGIS license information.  Watch for port numbers.^</li^>  >> %REPORT_FILE%
echo		^<li^>If "Borrow" has entries after it, a license has been borrowed.^</li^>^</ul^>  >> %REPORT_FILE%

:: Tell the customer what we are doing
	echo Scanning Registry...

:: These commands grab the Registry information
:: The wow6432node entries are for 32-bit programs installed on a 64-bit OS.
	echo ^<h3^>FME^</h3^> >> %REPORT_FILE%
	echo ^<pre^> >> %REPORT_FILE%
	echo ^<b^>On a 64-bit OS, any wow6432node entries indicate a 32-bit FME installation.^</b^> ^<br^> >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\Safe Software Inc." >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\Safe Software Inc.\Feature Manipulation Engine" >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\Safe Software Inc.\Feature Manipulation Engine\BUILD" >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\Safe Software Inc.\Feature Manipulation Engine\Extensions" /s >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\wow6432node\Safe Software Inc." >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\wow6432node\Safe Software Inc.\Feature Manipulation Engine" >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\wow6432node\Safe Software Inc.\Feature Manipulation Engine\BUILD" >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\wow6432node\Safe Software Inc.\Feature Manipulation Engine\Extensions" /s >> %REPORT_FILE%
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Safe Software Inc.\FME Objects\OEM" /s >> %REPORT_FILE%
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\wow6432node\Safe Software Inc.\FME Objects\OEM" /s >> %REPORT_FILE%
	echo  ^<b^>If a non-default Python interpreter is being used, it will be listed below  ^</b^> ^<br^> >> %REPORT_FILE
	reg query "HKEY_CURRENT_USER\Software\Safe Software Inc.\Feature Manipulation Engine\Python" >> %REPORT_FILE%
	echo  ^<b^>If Proxy settings are used, it will be listed below  ^</b^> ^<br^> >> %REPORT_FILE
	reg query "HKEY_CURRENT_USER\Software\Safe Software Inc.\FME Workbench\Settings" >> %REPORT_FILE%	
	echo ^</pre^> >> %REPORT_FILE%
	
	echo ^<h3^>ESRI^</h3^> >> %REPORT_FILE%
	echo ^<pre^> >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\ESRI" /s >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\wow6432node\ESRI" /s >> %REPORT_FILE%
	echo ^</pre^> >> %REPORT_FILE%
	
	echo ^<h3^>Autodesk^</h3^> >> %REPORT_FILE%
	echo ^<pre^> >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\Autodesk" /s >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\wow6432node\Autodesk" /s >> %REPORT_FILE%
	echo ^</pre^> >> %REPORT_FILE%
	
        echo ^<h3^>MapInfo^</h3^> >> %REPORT_FILE%
	echo ^<pre^> >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\MapInfo" /s >> %REPORT_FILE%
	reg query "HKLM\SOFTWARE\wow6432node\MapInfo" /s >> %REPORT_FILE%
	echo ^</pre^> >> %REPORT_FILE%
	
	echo ^<h3^>Oracle^</h3^> >> %REPORT_FILE%
	echo ^<pre^> >> %REPORT_FILE%
	reg query hklm\software\oracle /s >> %REPORT_FILE%
	reg query hklm\software\wow6432node\oracle /s >> %REPORT_FILE%
	echo ^</pre^> >> %REPORT_FILE%
	
	call:htmlSectionFooter
	call:htmlSectionHeader machinekey "Machine Key (Registration Code)"

	
echo Here is the Machine Key or Registration Code ^<br /^>  >> %REPORT_FILE%
echo 	Ensure that is is the same as what is  >> %REPORT_FILE%
echo 	listed in the license files below.  >> %REPORT_FILE%
echo ^<pre^>  >> %REPORT_FILE%

:: Find the expected Machine Key AKA Registration Code
:: This will use the first FME installation in the PATH. 
:: If we break this again, like we did in 2003, we may have to update this command.
	fmelicensingassistant_cmd --key >>%REPORT_FILE%
	echo ^</pre^>  >> %REPORT_FILE%
	
	call:htmlSectionFooter
	call:htmlSectionHeader FMEInstalls "FME Installations"
	
echo Here are all of the FME.EXE installed and in the path  >> %REPORT_FILE%
echo ^<pre^>  >> %REPORT_FILE%

:: Tell the customer what we are doing
	echo Searching for FME...

:: These first two lines parse the PATH variable.  We then search each folder in the path for FME.EXE.
	SET TempPath="%Path:;=";"%"
	FOR %%a IN (%TempPath%) DO (
		for %%F in ("%%~a\*fme.exe") do (
			echo FME found at
			echo %%F
			echo ***************************************************************************  >> %REPORT_FILE%
			echo FME found at:  >> %REPORT_FILE%
			echo %%F  >> %REPORT_FILE%
			echo ***************************************************************************  >> %REPORT_FILE%
			echo.  >> %REPORT_FILE%

			echo Finding installer information...	
			echo Installed using:  >> %REPORT_FILE%
			type "%%~dpF\eval_info.txt" >> %REPORT_FILE%
			echo.  >> %REPORT_FILE%

			echo The contents of the Licenses folder are:  >> %REPORT_FILE%
			dir "%%~dpF\licenses\*.*" /b  >> %REPORT_FILE%

				FOR %%I in ("%%~dpF\licenses\*.*") DO (
					echo.  >> %REPORT_FILE%
					echo The contents of >> %REPORT_FILE%
					echo %%I >> %REPORT_FILE%
					echo.  >> %REPORT_FILE%
					type "%%I" >> %REPORT_FILE% 
					echo.  >> %REPORT_FILE%
				)
				
			echo The contents of the parlic folder are:  >> %REPORT_FILE%
			dir "%%~dpF\parlic\*.*" /b  >> %REPORT_FILE%

				FOR %%I in ("%%~dpF\parlic\*.*") DO (
					echo.  >> %REPORT_FILE%
					echo The contents of >> %REPORT_FILE%
					echo %%I >> %REPORT_FILE%
					echo.  >> %REPORT_FILE%
					type "%%I" >> %REPORT_FILE% 
					echo.  >> %REPORT_FILE%
				)
				
			echo Looking for more FME installations...
			echo.  >> %REPORT_FILE%
		)
	)
	
:: There is also a chance that the user has a license file in their
:: My Documents OR Documents \FME\licenses folder, so we should grab that info too

	echo The contents of: >> %REPORT_FILE%
	echo %USERPROFILE%\My Documents\FME\licenses are: >> %REPORT_FILE%
			dir "%USERPROFILE%\My Documents\FME\licenses\*.*" /b  >> %REPORT_FILE%

				FOR %%I in ("%USERPROFILE%\My Documents\FME\licenses\*.*") DO (
					echo.  >> %REPORT_FILE%
					echo The contents of >> %REPORT_FILE%
					echo %%I >> %REPORT_FILE%
					echo.  >> %REPORT_FILE%
					type "%%I" >> %REPORT_FILE% 
					echo.  >> %REPORT_FILE%
				)

	echo The contents of: >> %REPORT_FILE%
	echo %USERPROFILE%\Documents\FME\licenses are: >> %REPORT_FILE%
			dir "%USERPROFILE%\Documents\FME\licenses\*.*" /b  >> %REPORT_FILE%

				FOR %%I in ("%USERPROFILE%\Documents\FME\licenses\*.*") DO (
					echo.  >> %REPORT_FILE%
					echo The contents of >> %REPORT_FILE%
					echo %%I >> %REPORT_FILE%
					echo.  >> %REPORT_FILE%
					type "%%I" >> %REPORT_FILE% 
					echo.  >> %REPORT_FILE%
				)

	echo The contents of: >> %REPORT_FILE%
	echo %ProgramData%\Safe Software\FME\Licenses are: >> %REPORT_FILE%
			dir "%ProgramData%\Safe Software\FME\Licenses\*.*" /b  >> %REPORT_FILE%

				FOR %%I in ("%ProgramData%\Safe Software\FME\Licenses\*.*") DO (
					echo.  >> %REPORT_FILE%
					echo The contents of >> %REPORT_FILE%
					echo %%I >> %REPORT_FILE%
					echo.  >> %REPORT_FILE%
					type "%%I" >> %REPORT_FILE% 
					echo.  >> %REPORT_FILE%
				)
	echo ^</pre^> >> %REPORT_FILE%
	
	call:htmlSectionFooter
	
	call:htmlSectionHeader nonex "Non-existent path entries"
:: Check for non-existent entries on the path. Report if missing.
echo Here are any PATH directories that do not actually exist (should be blank.)  >> %REPORT_FILE%
echo ^<pre^>  >> %REPORT_FILE%
	
	SET TempPath="%Path:;=";"%"
	FOR %%a IN (%TempPath%) DO (
		if not %%a == "" (
			IF NOT EXIST %%a call:pathNE %%a
		)
	)
	
echo ^</pre^> >> %REPORT_FILE%

	call:htmlSectionFooter
		
	call:htmlSectionHeader serverserv "FME Server Services"
:: Check for FME Services and report information
echo Here is a list of the FME Server Services  >> %REPORT_FILE%
echo ^<pre^>  >> %REPORT_FILE%
wmic service where "name like 'FME%%' or name like '%%smtprelay%%'" get caption,startname,state >> %REPORT_FILE%
echo ^</pre^> >> %REPORT_FILE%

	call:htmlSectionFooter

	call:htmlSectionHeader firewallst "Firewall Status"
:: Check if firewall on/off
echo Here is the Firewall status for Domain Private Public  >> %REPORT_FILE%
echo ^<pre^>  >> %REPORT_FILE%
netsh advfirewall show all state >> %REPORT_FILE%
echo ^</pre^> >> %REPORT_FILE%

	call:htmlSectionFooter

	call:htmlSectionHeader portst "Port Status"
:: Check for Port state and PID 
echo Here is the Port status for common FME processes.  >> %REPORT_FILE%
echo check running processes above using PID to see what is using the Port  >> %REPORT_FILE%
echo ^<pre^>  >> %REPORT_FILE%
netstat -noa |find "Proto" >> %REPORT_FILE%
netstat -noa |find /I "0.0.0.0:25" >> %REPORT_FILE% 
netstat -noa |find /I "0.0.0.0:80" >> %REPORT_FILE%
netstat -noa |find /I "0.0.0.0:110" >> %REPORT_FILE%
netstat -noa |find /I ":7070" >> %REPORT_FILE%
netstat -noa |find /I ":7071" >> %REPORT_FILE%
netstat -noa |find /I ":7072" >> %REPORT_FILE%
netstat -noa |find /I ":7073" >> %REPORT_FILE%
netstat -noa |find /I ":7074" >> %REPORT_FILE%
netstat -noa |find /I ":7075" >> %REPORT_FILE%
netstat -noa |find /I ":7076" >> %REPORT_FILE%
netstat -noa |find /I ":7077" >> %REPORT_FILE%
netstat -noa |find /I ":7078" >> %REPORT_FILE%
netstat -noa |find /I ":7079" >> %REPORT_FILE%
netstat -noa |find /I ":7082" >> %REPORT_FILE%
netstat -noa |find /I ":7500" >> %REPORT_FILE%
netstat -noa |find /I ":465" >> %REPORT_FILE%
netstat -noa |find /I ":995" >> %REPORT_FILE%
echo ^</pre^> >> %REPORT_FILE%

	call:htmlSectionFooter
	
	call:htmlSectionHeader hostsfile "Host File"
:: Dump Contents of host file to report 
echo Here is complete contents of the hosts file  >> %REPORT_FILE%
echo ^<pre^>  >> %REPORT_FILE%
more %SystemRoot%\System32\drivers\etc\hosts >> %REPORT_FILE%
echo ^</pre^> >> %REPORT_FILE%

	call:htmlSectionFooter
	
:: Output the HTML footer section
	call:htmlFooter

:: Copy the report to the desktop to make life easier for the customer.
	copy %REPORT_FILE% "%USERPROFILE%\Desktop\"

:: Clear the screen, and change color to grab attention
	cls
	color 0a


:: Tell the customer what to do
	Echo Please email %REPORT_FILE% to support@safe.com
	echo.
	echo A copy of %REPORT_FILE% is on your Desktop
	echo.
	echo Thank You!
	echo.
	pause
	
	color 0F
	
goto:eof

:: Functions here

:fileContents
echo Contents of >> %REPORT_FILE%
echo %~1 >> %REPORT_FILE%
echo *************************************************************************** >> %REPORT_FILE%
echo. >> %REPORT_FILE%
type %~1 >> %REPORT_FILE%
goto:eof

:dirContents
echo Contents of >> %REPORT_FILE%
echo %~1 >> %REPORT_FILE%
echo *************************************************************************** >> %REPORT_FILE%
echo. >> %REPORT_FILE%
dir %~1 >> %REPORT_FILE%
goto:eof

:pathNE
echo Uh oh, >> %REPORT_FILE%
echo %~1 >> %REPORT_FILE%
echo is in the system path, but doesn't exist. >> %REPORT_FILE%
echo. >> %REPORT_FILE%
goto:eof

:htmlHeader
echo ^<^^!doctype html^> > %REPORT_FILE%
echo ^<html^>^<head^> >> %REPORT_FILE%
echo ^<title^>FME Troubleshooting Report^</title^> >> %REPORT_FILE%
echo ^</head^> >> %REPORT_FILE%
echo ^<body^> >> %REPORT_FILE%
echo ^<h1^>FME Troubleshooting Report^</h1^> >> %REPORT_FILE%
echo ^<h2^>Contents^</h2^> >> %REPORT_FILE%
echo ^<ul^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#sysinfo"^>System Information^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#processes"^>Running Processes^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#envvar"^>Environment Variables^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#sdelib"^>SDE Libraries^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#oractns"^>Oracle^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#autodesk"^>Autodesk^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#registry"^>Registry^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#machinekey"^>Machine Key (Registration Code)^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#FMEInstalls"^>FME Installations^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#nonex"^>Non-existent Path Entries^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#serverserv"^>FME Server Services^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#firewallst"^>Firewall Status^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#portst"^>Port Status^</a^>^</li^> >> %REPORT_FILE%
echo ^<li^> ^<a href="#hostsfile"^>Hosts File^</a^>^</li^> >> %REPORT_FILE%
echo ^</ul^> >> %REPORT_FILE%
echo ^<hr /^> >> %REPORT_FILE%

goto:eof

:htmlFooter
echo End of report. >> %REPORT_FILE%
echo ^</body^>^</html^> >> %REPORT_FILE%
goto:eof

:htmlSectionHeader
echo ^<a id="%~1"^> >> %REPORT_FILE%
echo ^<h2^>%~2^</h2^> >> %REPORT_FILE%
echo ^</a^> >> %REPORT_FILE%
goto:eof

:htmlSectionFooter
echo ^<a href="#top"^>Back to top^</a^> >> %REPORT_FILE%
echo ^<hr /^> >> %REPORT_FILE%
goto:eof
