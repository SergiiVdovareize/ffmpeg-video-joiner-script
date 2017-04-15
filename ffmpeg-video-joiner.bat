@echo off

echo.
echo.
echo ------------------------------------------------
echo -- LETS MERGE VIDEO SEGMENTS INTO FULL VIDEOS --
echo ------------------------------------------------

set list_prefix=__list.txt
set videos_out=full_matches_output
set format=.mp4
set source=%1
set do_merge=1

if not exist %source% goto no_source

:create_lists
	cd /d %source%
	echo.
	echo 1. GO THROUGH ALL GAMES TO CREATE FILE LISTS FOR FFMPEG
	for /f "delims=" %%d in ('dir /ad /b %source%') do (
		if not "%%d" == "%videos_out%" (
			echo  - CREATE LIST: %%d
			(for /f "delims=" %%f in ('dir /b /od "%%d\*.mp4"') do @echo file '%%f') > "%%d/%%d%list_prefix%"
		)
	)

if %do_merge% == 0 goto finish
	
:merge_parts
	echo.
	echo 2. GO THROUGH ALL GAMES TO MERGE VIDEOS
	
	if not exist %videos_out% mkdir %videos_out%
	
	for /f "delims=" %%d in ('dir /ad /b') do (
		if not "%%d" == "%videos_out%" (
			if exist %videos_out%/%%d%format% (
				echo  - FILE EXISTS, SKIP: %videos_out%/%%d%format%
			) else (	
				echo  - MERGE VIDEO: %%d
				ffmpeg -stats -v error -f concat -safe 0 -i "%%d/%%d%list_prefix%" -c copy "%videos_out%/%%d%format%" -y
			)
		)
	)
	
goto finish
	
:no_source
	echo.
	echo source folder does not exist - %source%

:finish
	echo.
	echo -- DONE --
	echo.
	pause
	exit /b