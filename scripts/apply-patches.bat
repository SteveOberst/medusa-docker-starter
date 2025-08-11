@echo off
setlocal enabledelayedexpansion
set BACKEND_DIR=%1
if "%BACKEND_DIR%"=="" set BACKEND_DIR=backend
set STOREFRONT_DIR=%2
if "%STOREFRONT_DIR%"=="" set STOREFRONT_DIR=storefront

if exist patch\backend (
  echo Applying patch from 'patch\backend' to '%BACKEND_DIR%'
  if not exist "%BACKEND_DIR%" mkdir "%BACKEND_DIR%"
  xcopy /E /I /Y patch\backend\* "%BACKEND_DIR%\" >nul
) else (
  echo No patch directory found at 'patch\backend' — skipping
)

if exist patch\storefront (
  echo Applying patch from 'patch\storefront' to '%STOREFRONT_DIR%'
  if not exist "%STOREFRONT_DIR%" mkdir "%STOREFRONT_DIR%"
  xcopy /E /I /Y patch\storefront\* "%STOREFRONT_DIR%\" >nul
) else (
  echo No patch directory found at 'patch\storefront' — skipping
)

echo Patches applied.
