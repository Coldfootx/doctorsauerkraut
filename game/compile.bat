powershell Compress-Archive .\source\game\* -Force .\source\game.zip
powershell Move-Item -Force -Path ".\source\game.zip" ".\source\game.love"

mkdir  .\compiled\game
copy /b .\love\love.exe+.\source\game.love .\compiled\game\game.exe
xcopy love .\compiled\game\ /s /e /y
REM /s /e full directories, /y force rewrite