@echo off
setlocal
set DETACHED=
set REBUILD=

:parse
if "%~1"=="" goto run
if /I "%~1"=="-d" set DETACHED=1
if /I "%~1"=="--detached" set DETACHED=1
if /I "%~1"=="--rebuild" set REBUILD=1
if /I "%~1"=="rebuild" set REBUILD=1
shift
goto parse

:run
set BUILD=
if defined REBUILD set BUILD=--build
set DET=
if defined DETACHED set DET=-d

docker compose up %BUILD% %DET%
