function Invoke-PowerShell {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Script,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string] $WorkingDirectory,

        [Parameter(Mandatory)]
        [ValidateRange(1, 3600)]
        [int] $TimeoutSeconds,

        [Parameter(Mandatory)]
        [ValidateRange(1, 10000000)]
        [int] $MaximumOutputCharacters
    )

    $executionId = [guid]::NewGuid().ToString()
    $startedAt = [datetime]::UtcNow
    $timedOut = $false
    $outputTruncated = $false
    $process = $null

    try {
        $encodedCommand = [Convert]::ToBase64String(
            [Text.Encoding]::Unicode.GetBytes($Script)
        )
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = 'pwsh.exe'
        $startInfo.WorkingDirectory = (Resolve-Path -LiteralPath $WorkingDirectory).Path
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        [void] $startInfo.ArgumentList.Add('-NoLogo')
        [void] $startInfo.ArgumentList.Add('-NoProfile')
        [void] $startInfo.ArgumentList.Add('-NonInteractive')
        [void] $startInfo.ArgumentList.Add('-EncodedCommand')
        [void] $startInfo.ArgumentList.Add($encodedCommand)

        $process = [System.Diagnostics.Process]::new()
        $process.StartInfo = $startInfo
        [void] $process.Start()
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            $timedOut = $true
            try {
                $process.Kill($true)
            } catch {
                throw "The PowerShell child process timed out and could not be terminated: $($_.Exception.Message)"
            }
            $process.WaitForExit()
        }

        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result
        if ($stdout.Length -gt $MaximumOutputCharacters) {
            $stdout = $stdout.Substring(0, $MaximumOutputCharacters)
            $outputTruncated = $true
        }
        if ($stderr.Length -gt $MaximumOutputCharacters) {
            $stderr = $stderr.Substring(0, $MaximumOutputCharacters)
            $outputTruncated = $true
        }

        [pscustomobject] @{
            ExecutionId = $executionId
            Success = (-not $timedOut -and $process.ExitCode -eq 0)
            ExitCode = $process.ExitCode
            StandardOutput = $stdout
            StandardError = $stderr
            TimedOut = $timedOut
            OutputTruncated = $outputTruncated
            WorkingDirectory = $startInfo.WorkingDirectory
            StartedAt = $startedAt
            CompletedAt = [datetime]::UtcNow
            DurationMilliseconds = ([datetime]::UtcNow - $startedAt).TotalMilliseconds
        }
    } finally {
        if ($process) { $process.Dispose() }
    }
}

Export-ModuleMember -Function Invoke-PowerShell
