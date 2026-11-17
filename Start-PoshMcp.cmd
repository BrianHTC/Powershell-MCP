@echo off
setlocal

rem Adjust this if your PoshMcp runtime config is stored elsewhere.
set "CONFIG=C:\TrustedTools\PoshMcpRuntime\appsettings.json"
set "PATH=%PATH%;%USERPROFILE%\.dotnet\tools"

if not exist "%CONFIG%" (
    echo ERROR: Configuration file not found:
    echo   %CONFIG%
    echo Complete the setup in README.md, then try again.
    pause
    exit /b 1
)

where pwsh.exe >nul 2>nul
if errorlevel 1 (
    echo ERROR: PowerShell 7 (pwsh.exe) was not found. Install PowerShell 7 and try again.
    pause
    exit /b 1
)

where poshmcp >nul 2>nul
if errorlevel 1 (
    echo ERROR: PoshMcp was not found. Install PoshMcp and try again.
    pause
    exit /b 1
)

echo Starting PoshMcp at http://127.0.0.1:8080/mcp
 echo Press Ctrl+C to stop the server. Close the window when finished.

pwsh.exe -NoLogo -NoProfile -NoExit -ExecutionPolicy Bypass -Command "$env:POSHMCP_CONFIGURATION = '%CONFIG%'; $env:POSHMCP_TRANSPORT = 'http'; $env:POSHMCP_MCP_PATH = '/mcp'; $env:ASPNETCORE_URLS = 'http://127.0.0.1:8080'; & poshmcp serve --config '%CONFIG%' --transport http --url 'http://127.0.0.1:8080' --mcp-path '/mcp'"

set "EXITCODE=%ERRORLEVEL%"
echo.
echo PoshMcp stopped with exit code %EXITCODE%.
pause
exit /b %EXITCODE%
