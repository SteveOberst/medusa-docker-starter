@echo off
setlocal
if /I "%~1"=="--prune" goto prune
if /I "%~1"=="prune" goto prune
docker compose down
goto :eof
:prune
docker compose down -v --remove-orphans
