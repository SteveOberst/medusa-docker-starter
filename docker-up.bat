@echo off
setlocal
if /I "%~1"=="--rebuild" goto rebuild
if /I "%~1"=="rebuild" goto rebuild
docker compose up -d
goto :eof
:rebuild
docker compose up --build -d
