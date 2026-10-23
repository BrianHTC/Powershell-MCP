# Powershell-Mcp

A bounded PowerShell fallback module for [PoshMcp](https://github.com/usepowershell/PoshMcp). Supports more Powershell commands. 

## Install

Copy the `InvokePowerShell` folder to a PowerShell 7 module directory:

```powershell
$moduleRoot = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules'
Copy-Item .\InvokePowerShell (Join-Path $moduleRoot 'InvokePowerShell') -Recurse -Force
Import-Module InvokePowerShell -Force
```

Configure PoshMcp to import `InvokePowerShell` and expose the `Invoke-PowerShell` command. Its MCP tool name is `invoke_power_shell`.

## Example

```powershell
Invoke-PowerShell `
  -Script 'Get-Date' `
  -WorkingDirectory (Get-Location).Path `
  -TimeoutSeconds 30 `
  -MaximumOutputCharacters 100000
```

The result includes execution ID, success state, exit code, stdout, stderr, timeout state, truncation state, working directory, timestamps, and duration.

## Safety

This module executes arbitrary PowerShell with the permissions of the hosting account. Run PoshMcp as a normal user, bind it to `127.0.0.1`, require authentication before remote exposure, and use explicit approvals for destructive or system-changing operations.

Do not commit API keys, tunnel credentials, private domains, or local runtime configuration.
