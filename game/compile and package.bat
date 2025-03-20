call compile.bat

powershell Compress-Archive .\compiled\game\* -Force .\package\game.zip
REM powershell Compress-Archive .\compiled\server\* .\package\server.zip