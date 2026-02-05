@echo off
setlocal enabledelayedexpansion

:: download_npiperelay.bat - Download and install npiperelay for Windows
:: This script downloads npiperelay, extracts it to AppData, and adds it to PATH

echo ========================================
echo npiperelay Installation Script
echo ========================================
echo.

:: Set variables
set "DOWNLOAD_URL=https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_amd64.zip"
set "ZIP_FILE=%TEMP%\npiperelay_windows_amd64.zip"
set "EXTRACT_DIR=%TEMP%\npiperelay_extract"
set "INSTALL_DIR=%LOCALAPPDATA%\npiperelay"

:: Check if curl is available
where curl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: curl is not available on this system.
    echo Please install curl or download npiperelay manually.
    pause
    exit /b 1
)

:: Check if tar is available (Windows 10 1803+ has built-in tar with zip support)
where tar >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: tar is not available on this system.
    echo Please use Windows 10 version 1803 or later, or extract manually.
    pause
    exit /b 1
)

:: Download npiperelay
echo Downloading npiperelay from GitHub...
echo URL: %DOWNLOAD_URL%
echo.
curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to download npiperelay.
    pause
    exit /b 1
)
echo Download completed successfully.
echo.

:: Create extract directory
if exist "%EXTRACT_DIR%" (
    echo Cleaning up old extraction directory...
    rmdir /s /q "%EXTRACT_DIR%"
)
mkdir "%EXTRACT_DIR%"

:: Extract zip file
echo Extracting archive...
tar -xf "%ZIP_FILE%" -C "%EXTRACT_DIR%"
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to extract archive.
    del "%ZIP_FILE%"
    pause
    exit /b 1
)
echo Extraction completed successfully.
echo.

:: Create installation directory
if not exist "%INSTALL_DIR%" (
    echo Creating installation directory: %INSTALL_DIR%
    mkdir "%INSTALL_DIR%"
) else (
    echo Installation directory already exists: %INSTALL_DIR%
    echo Replacing existing files...
)

:: Copy npiperelay.exe to installation directory
echo Copying npiperelay.exe to %INSTALL_DIR%...
copy /Y "%EXTRACT_DIR%\npiperelay.exe" "%INSTALL_DIR%\npiperelay.exe" >nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to copy npiperelay.exe to installation directory.
    del "%ZIP_FILE%"
    rmdir /s /q "%EXTRACT_DIR%"
    pause
    exit /b 1
)
echo Copy completed successfully.
echo.

:: Clean up temporary files
echo Cleaning up temporary files...
del "%ZIP_FILE%"
rmdir /s /q "%EXTRACT_DIR%"
echo Cleanup completed.
echo.

:: Check if PATH already contains the installation directory
echo %PATH% | findstr /C:"%INSTALL_DIR%" >nul
if %ERRORLEVEL% EQU 0 (
    echo Installation directory is already in PATH.
) else (
    echo Adding %INSTALL_DIR% to user PATH...
    setx PATH "%PATH%;%INSTALL_DIR%"
    if %ERRORLEVEL% EQU 0 (
        echo PATH updated successfully.
        echo.
        echo IMPORTANT: Please restart your terminal or WSL session for PATH changes to take effect.
    ) else (
        echo Warning: Failed to update PATH automatically.
        echo Please manually add %INSTALL_DIR% to your PATH environment variable.
    )
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo npiperelay.exe has been installed to:
echo %INSTALL_DIR%
echo.
echo To verify installation, open a new terminal and run:
echo   npiperelay.exe -h
echo.
echo You can now proceed with the relay-ssh-agent installation in WSL.
echo.
pause
