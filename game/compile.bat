powershell Compress-Archive .\source\game\* -Force .\source\game.zip
powershell Move-Item -Force -Path ".\source\game.zip" ".\source\game.love"

mkdir .\compiled\game
copy /b .\love\love.exe+.\source\game.love .\compiled\game\game.exe
robocopy love .\compiled\game\ /is /it /E