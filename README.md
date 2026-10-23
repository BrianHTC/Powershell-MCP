# Powershell-Mcp

A bounded PowerShell fallback module for [PoshMcp](https://github.com/usepowershell/PoshMcp). Supports more Powershell commands. 

## Install

Install PoshMcp first. Check the prerequisites. 

Copy the `InvokePowerShell.psm1` file in a `InvokePowerShell` folder and copy it to a PowerShell 7 module directory:

```powershell
$moduleRoot = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules'
Copy-Item .\InvokePowerShell (Join-Path $moduleRoot 'InvokePowerShell') -Recurse -Force
Import-Module InvokePowerShell -Force
```

Configure PoshMcp to import `InvokePowerShell` and expose the `Invoke-PowerShell` command. Its MCP tool name is `invoke_power_shell`.

## Start PoshMcp locally

Open PowerShell 7 and set the runtime configuration and local HTTP endpoint:

```powershell
$env:Path += ";$HOME\.dotnet\tools"
$env:POSHMCP_CONFIGURATION = "C:\TrustedTools\PoshMcpRuntime\appsettings.json"
$env:POSHMCP_TRANSPORT = "http"
$env:POSHMCP_MCP_PATH = "/mcp"
$env:ASPNETCORE_URLS = "http://127.0.0.1:8080"
```

Start the server:

```powershell
poshmcp serve `
  --config "C:\TrustedTools\PoshMcpRuntime\appsettings.json" `
  --transport http `
  --url "http://127.0.0.1:8080" `
  --mcp-path "/mcp"
```

Keep this window open while PoshMcp is running. The local MCP endpoint is:

```text
http://127.0.0.1:8080/mcp
```

In a second PowerShell 7 window, verify the server:

```powershell
Invoke-WebRequest "http://127.0.0.1:8080/health" -UseBasicParsing
Invoke-WebRequest "http://127.0.0.1:8080/health/ready" -UseBasicParsing
```

Both requests should return HTTP `200`.

### Test with MCP Inspector

List the available tools:

```powershell
npx.cmd --yes @modelcontextprotocol/inspector `
  --cli `
  --transport http `
  --server-url "http://127.0.0.1:8080/mcp" `
  --protocol-era modern `
  --method tools/list
```

Test `invoke_power_shell`:

```powershell
npx.cmd --yes @modelcontextprotocol/inspector `
  --cli `
  --transport http `
  --server-url "http://127.0.0.1:8080/mcp" `
  --protocol-era modern `
  --method tools/call `
  --tool-name invoke_power_shell `
  --tool-arg Script="Write-Output inspector-ok" `
  --tool-arg WorkingDirectory="C:\TrustedTools\PoshMcpRuntime" `
  --tool-arg TimeoutSeconds=10 `
  --tool-arg MaximumOutputCharacters=1000
```

The result should report `Success: true`, `ExitCode: 0`, and `inspector-ok`.

Stop the local server with `Ctrl+C` in the PoshMcp window.

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
