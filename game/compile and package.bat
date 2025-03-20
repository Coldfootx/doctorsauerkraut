call compile.bat

mkdir .\package
powershell Compress-Archive .\compiled\game\* -Force .\package\game.zip
REM powershell Compress-Archive .\compiled\server\* .\package\server.zip