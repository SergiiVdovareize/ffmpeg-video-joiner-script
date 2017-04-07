@echo off

echo.
echo.
echo ------------------------------------------------
echo -- LETS MERGE VIDEO SEGMENTS INTO FULL VIDEOS --
echo ------------------------------------------------

set list_prefix=__list.txt
set videos_out=c:/videos
set format=.mp4

echo.
echo 1. GO THROUGH ALL GAMES TO CREATE FILE LISTS FOR FFMPEG
for /f "delims=" %%d in ('dir /ad /b') do (
	echo  - CREATE LIST: %%d
	(for /f "delims=" %%f in ('dir /b /od "%%d\*.mp4"') do @echo file '%%f') > "%%d/%%d%list_prefix%"
)

echo.
echo 2. GO THROUGH ALL GAMES TO MERGE VIDEOS
for /f "delims=" %%d in ('dir /ad /b') do (
	if exist %videos_out%/%%d%format% (
		echo  - FILE EXISTS, SKIP: %videos_out%/%%d%format%
	) else (	
		echo  - MERGE VIDEO: %%d
		ffmpeg -stats -v error -f concat -safe 0 -i "%%d/%%d%list_prefix%" -c copy "%videos_out%/%%d%format%" -y
	)
)

echo.
echo 3. FINAL STEP

echo.
echo -- DONE --
echo.
pause
