# Security

`Invoke-PowerShell` is intentionally powerful. Anyone authorized to call the containing MCP server can execute commands as the Windows account running PoshMcp.

- Run PoshMcp as a normal user, never as Administrator.
- Keep the HTTP origin bound to `127.0.0.1`.
- Enable API-key authentication before using a tunnel.
- Keep runtime configuration and Cloudflare credentials outside Git.
- Use timeouts and output limits.
- Require approval for installation, deletion, Git changes, uploads, downloads, and system configuration.
