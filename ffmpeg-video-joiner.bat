@echo off

MODE 140,40

:: config
set list_prefix=__list.txt
set videos_out=!full_matches_output
set format=.mp4
set source=%1
set lof_file=joiner.log

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

:: get start time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

:: use current path as a source path if dot is passed
if "%source%" == "." set source=%cd%

:: check if source dir is not empty and exists
if "%source%" == "" goto no_param
if not exist %source% goto no_source

cd /d %source%
echo. >> %lof_file%
echo -- Joiner script started. Time: %time% >> %lof_file% --

:create_lists
	:: go through all folders and creates file lists for joining by ffmpeg
	echo.
	
	set msg=1. Go through all games to create file lists for joining
	echo %msg%
	echo %msg% >> %lof_file%
	
	set msg= source: %source%
	echo %msg%
	echo %msg% >> %lof_file%
	
	for /f "delims=" %%d in ('dir /ad /b %source%') do (
		:: skip output folder
		if not "%%d" == "%videos_out%" (
			set /a found=found+1
			
			echo  - create list: %%d
			echo  - create list: %%d >> %lof_file%
			
			(for /f "delims=" %%f in ('dir /b /od "%%d\*.mp4"') do @echo file '%%f') > "%%d/%%d%list_prefix%"
		)
	)

if %do_merge% == 0 goto finish
	
:merge_parts
	:: go through all prepared games and join their videos based on their file list created earlier
	echo.
	set msg=2. Go through all games to merge videos
	echo %msg%
	echo %msg% >> %lof_file%
	
	:: create output folder if it does not exist
	if not exist %videos_out% mkdir %videos_out%
	
	for /f "delims=" %%d in ('dir /ad /b') do (
		:: skip output folder
		if not "%%d" == "%videos_out%" (
			:: check if output video was joined and saved earlier
			if exist %videos_out%/%%d%format% (
				:: skip if was
				echo  - file exists, skip: %videos_out%/%%d%format%
				echo  - file exists, skip: %videos_out%/%%d%format% >> %lof_file%
				set /a skipped=skipped+1
			) else (
				:: do joining using ffmpeg lib and based on a filelist created on the step 1
				echo  - merge video: %%d
				echo  - merge video: %%d >> %lof_file%
				ffmpeg -stats -v error -f concat -safe 0 -i "%%d/%%d%list_prefix%" -c copy "%videos_out%/%%d%format%" -y
				set /a merged=merged+1
			)
		)
	)
	
if %upload% == 0 goto finish

:upload
	echo.
	set msg=3. Upload merged videos to youtube
	echo %msg%
	echo %msg% >> %lof_file%
	
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
	
	echo Result: >> %lof_file%
	echo  - found %found% videos >> %lof_file%
	echo  - merged %merged% videos >> %lof_file%
	echo  - skipped %skipped% videos >> %lof_file%
	echo  - elapsed time: %hh%:%mm%:%ss% >> %lof_file%
	echo ---------------------------------- >> %lof_file%
	pause
	exit /b