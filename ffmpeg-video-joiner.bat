@echo off

:: config
set list_prefix=__list.txt
set videos_out=!full_matches_output
set format=.mp4
set source=%1

:: flags
set do_merge=1
set upload=0

:: counters
set found=0
set merged=0
set skipped=0

cls
echo ------------------------------------------------
echo -- LETS MERGE VIDEO SEGMENTS INTO FULL VIDEOS --
echo ------------------------------------------------

:: use current path as a source path if dot is passed
if "%source%" == "." set source=%cd%

:: check if source dir is not empty and exists
if "%source%" == "" goto no_param
if not exist %source% goto no_source

:create_lists
	:: go through all folders and creates file lists for joining by ffmpeg
	cd /d %source%
	echo.
	echo 1. Go through all games to create file lists for joining
	for /f "delims=" %%d in ('dir /ad /b %source%') do (
		:: skip output folder
		if not "%%d" == "%videos_out%" (
			set /a found=found+1
			echo  - create list: %%d
			(for /f "delims=" %%f in ('dir /b /od "%%d\*.mp4"') do @echo file '%%f') > "%%d/%%d%list_prefix%"
		)
	)

if %do_merge% == 0 goto finish
	
:merge_parts
	:: go through all prepared games and join their videos based on their file list created earlier
	echo.
	echo 2. Go through all games to merge videos
	
	:: create output folder if it does not exist
	if not exist %videos_out% mkdir %videos_out%
	
	for /f "delims=" %%d in ('dir /ad /b') do (
		:: skip output folder
		if not "%%d" == "%videos_out%" (
			:: check if output video was joined and saved earlier
			if exist %videos_out%/%%d%format% (
				:: skip if was
				echo  - file exists, skip: %videos_out%/%%d%format%
				set /a skipped=skipped+1
			) else (
				:: do joining using ffmpeg lib and based on a filelist created on the step 1
				echo  - merge video: %%d
				ffmpeg -stats -v error -f concat -safe 0 -i "%%d/%%d%list_prefix%" -c copy "%videos_out%/%%d%format%" -y
				set /a merged=merged+1
			)
		)
	)
	
if %upload% == 0 goto finish

:upload
	echo.
	echo 3. Upload merged videos to youtube
	
goto finish

:no_param
	echo.
	echo ERROR: pass source folder as a parameter
	goto finish
	
:no_source
	echo.
	echo ERROR: source folder does not exist - %source%
	goto finish

:finish
	echo.
	echo Result:
	echo  - found %found% videos
	echo  - merged %merged% videos
	echo  - skipped %skipped% videos
	echo.
	pause
	exit /b