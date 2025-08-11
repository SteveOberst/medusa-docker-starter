@echo off
setlocal enabledelayedexpansion

REM Move to repo root (this script's parent directory)
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."

REM Load .env if present (simple KEY=VALUE parser; ignores comments)
if exist .env (
  for /f "usebackq tokens=1,2 delims==" %%A in (".env") do (
    set k=%%A
    set v=%%B
    if not "!k!"=="" if not "!k:~0,1!"=="#" set !k!=!v!
  )
)

set BACKEND_DIR=%BACKEND_DIR%
if "%BACKEND_DIR%"=="" set BACKEND_DIR=backend
set STOREFRONT_DIR=%STOREFRONT_DIR%
if "%STOREFRONT_DIR%"=="" set STOREFRONT_DIR=storefront
set STOREFRONT_REPO=%STOREFRONT_REPO%
if "%STOREFRONT_REPO%"=="" set STOREFRONT_REPO=https://github.com/medusajs/nextjs-starter-medusa
set STOREFRONT_REF=%STOREFRONT_REF%
if "%STOREFRONT_REF%"=="" set STOREFRONT_REF=main
set BACKEND_REPO=%BACKEND_REPO%
if "%BACKEND_REPO%"=="" set BACKEND_REPO=https://github.com/medusajs/medusa-starter-default
set BACKEND_REF=%BACKEND_REF%
if "%BACKEND_REF%"=="" set BACKEND_REF=master
set BACKEND_INIT_CMD=%BACKEND_INIT_CMD%
if "%BACKEND_INIT_CMD%"=="" set BACKEND_INIT_CMD=npx create-medusa-app@latest {dir}

REM Reset a directory (delete then recreate)
set RESET_DIR_CMD=rmdir /S /Q "%%1" ^&^& mkdir "%%1"

echo Preparing backend directory: %BACKEND_DIR%
call :reset_dir "%BACKEND_DIR%"
if not "%BACKEND_REPO%"=="" (
  echo Cloning backend from %BACKEND_REPO%@%BACKEND_REF% into %BACKEND_DIR%
  git clone --depth 1 --branch %BACKEND_REF% %BACKEND_REPO% "%BACKEND_DIR%"
) else (
  call :init_backend "%BACKEND_DIR%"
)

echo Bootstrapping storefront from %STOREFRONT_REPO%@%STOREFRONT_REF% into %STOREFRONT_DIR%
call :reset_dir "%STOREFRONT_DIR%"
git clone --depth 1 --branch %STOREFRONT_REF% %STOREFRONT_REPO% "%STOREFRONT_DIR%"

scripts\apply-patches.bat "%BACKEND_DIR%" "%STOREFRONT_DIR%"

if exist .env.template if not exist .env (
  copy /Y .env.template .env >nul
  echo Created .env from .env.template
)

echo Bootstrap complete. Run: docker compose up --build
goto :eof

:init_backend
set DIR=%~1
set CMD=%BACKEND_INIT_CMD:{dir}=%DIR%%
if "%CMD%"=="%BACKEND_INIT_CMD%" set CMD=%BACKEND_INIT_CMD% %DIR%
echo Initializing backend using: %CMD%
cmd /c %CMD%
goto :eof

:reset_dir
set DIR=%~1
if exist "%DIR%" rmdir /S /Q "%DIR%"
mkdir "%DIR%"
goto :eof
