@echo off

MODE 140,40

:: config
set list_prefix=__list.txt
set videos_out=!full_matches_output
set format=.mp4
set source=%1
set log_file=joiner.log

:: flags
set do_merge=1

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

:: get start time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

cd /d %source%
echo. >> %log_file%
echo -- Joiner script started. Time: %time% >> %log_file% --

:create_lists
	echo.
	set msg=[source: %source%]
	echo %msg%
	echo %msg% >> %log_file%
	
	:: go through all folders and creates file lists for joining by ffmpeg
	echo.
	set msg=1. Go through all games to create file lists for joining
	echo %msg%
	echo %msg% >> %log_file%
	
	for /f "delims=" %%d in ('dir /ad /b %source%') do (
		:: skip the output folder
		if not "%%d" == "%videos_out%" (
			:: skip folder if there are no needed files
			if exist "%%d\*%format%" (
				set /a found=found+1
				echo  - create list: %%d
				echo  - create list: %%d >> %log_file%
				(for /f "delims=" %%f in ('dir /b /od "%%d\*%format%"') do @echo file '%%f') > "%%d/%%d%list_prefix%"
			) else (
				echo  - no %format% files inside folder '%%d'
			)
		)
	)

if %do_merge% == 0 goto finish
	
:merge_parts
	:: go through all prepared games and join their videos based on their file list created earlier
	echo.
	set msg=2. Go through all games to merge videos
	echo %msg%
	echo %msg% >> %log_file%
	
	:: create output folder if it does not exist
	if not exist %videos_out% mkdir %videos_out%
	
	for /f "delims=" %%d in ('dir /ad /b') do (
		:: skip output folder
		if not "%%d" == "%videos_out%" (
			:: check if output video was joined and saved earlier
			if exist %videos_out%/%%d%format% (
				:: skip earlier joined videos
				echo  - file exists, skip: %videos_out%/%%d%format%
				echo  - file exists, skip: %videos_out%/%%d%format% >> %log_file%
				set /a skipped=skipped+1
			) else (
				if exist "%%d\*%format%" (
					:: do joining using ffmpeg lib and based on a filelist created on the step 1
					echo  - merge video: %%d
					echo  - merge video: %%d >> %log_file%
					ffmpeg -stats -v error -f concat -safe 0 -i "%%d/%%d%list_prefix%" -c copy "%videos_out%/%%d%format%" -y
					set /a merged=merged+1
				)
			)
		)
	)
	
goto finish

:no_param
	echo.
	echo ERROR: pass source folder as a parameter
	goto finish
	
:no_source
	echo.
	echo ERROR: pass source folder as a parameter
	goto finish

:finish
	:: get end time:
	for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
	   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
	)
	
	:: get elapsed time:
	set /A elapsed=end-start
	
	:: show elapsed time:
	set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
	if %hh% lss 10 set hh=0%hh%
	if %mm% lss 10 set mm=0%mm%
	if %ss% lss 10 set ss=0%ss%

	echo.
	echo Result:
	echo  - found %found% videos
	echo  - merged %merged% videos
	echo  - skipped %skipped% videos
	echo  - elapsed time: %hh%:%mm%:%ss%
	echo.
	
	echo Result: >> %log_file%
	echo  - found %found% videos >> %log_file%
	echo  - merged %merged% videos >> %log_file%
	echo  - skipped %skipped% videos >> %log_file%
	echo  - elapsed time: %hh%:%mm%:%ss% >> %log_file%
	echo ---------------------------------- >> %log_file%
	