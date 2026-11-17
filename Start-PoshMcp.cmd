@echo off
title PoshMcp

set "CONFIG=C:\TrustedTools\PoshMcpRuntime\appsettings.json"

pwsh.exe -NoExit -ExecutionPolicy Bypass -Command ^
"$env:POSHMCP_CONFIGURATION='%CONFIG%'; ^
 $env:POSHMCP_TRANSPORT='http'; ^
 $env:POSHMCP_MCP_PATH='/mcp'; ^
 $env:ASPNETCORE_URLS='http://127.0.0.1:8080'; ^
 poshmcp serve --config '%CONFIG%' --transport http --url 'http://127.0.0.1:8080' --mcp-path '/mcp'"
