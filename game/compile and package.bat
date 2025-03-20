call compile.bat

mkdir .\package
powershell Compress-Archive .\compiled\game\* -Force .\package\game.zip