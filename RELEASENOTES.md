# RELEASE NOTES

    - 2021-11-04 - Name resolution now also looks to host files to check if HOST file entry match Public DNS entry
    - 2022-01-21 - Shows note when open dns / cx dns name resultion fail
                 - Fix for when name resultion fails "No such host is known". Sample workspaces conected to former SQL DW does not resolve SERVERNAME.sql.azuresynapse.net
    - 2022-04-14 - 1443 port NOT needed anymore. Portal using only 443 now - documented in march https://docs.microsoft.com/en-us/azure/synapse-analytics/security/synapse-workspace-ip-firewall#connect-to-azure-synapse-from-your-own-network
                 - Improve message cx and public dns ips are not same
                 - Add method to get browser proxy and SHIR proxy settings
    - 2022-06-25 - 1443 port added back to document (we use this port in certain regions) - https://docs.microsoft.com/en-us/azure/synapse-analytics/security/synapse-workspace-ip-firewall#connect-to-azure-synapse-from-your-own-network
                 - ADDED AAD login endpoints (login.windows.net / login.microsoftonline.com / secure.aadcdn.microsoftonline-p.com). took from https://github.com/Azure/SQL-Connectivity-Checker/blob/master/AzureSQLConnectivityChecker.ps1
                 - Change code to Classes
    - 2022-06-30 - Fixed error "The output stream for this command is already redirected"
					Error caused by write output + char > causing redirect of output
    - 2022-10-31 - 1433 added again. Still needed in some regions for Synapse Studio
                   - https://docs.microsoft.com/en-us/azure/synapse-analytics/security/synapse-workspace-ip-firewall#connect-to-azure-synapse-from-your-own-network
                   - https://github.com/MicrosoftDocs/azure-docs/issues/69090
                 - Added Import-Module DnsClient just in case is not there by default - BUGFIX
                 - When name resolution fails. Test port shows CLOSED
                 - Check if machine is windows before executing. Not tested on Linux or Mac
    - 2023-03-08 - Test AAD Login endpoints ("login.windows.net" / "login.microsoftonline.com" / "secure.aadcdn.microsoftonline-p.com")
    - 2023-04-20 - Code organization
                 - Make API test calls
                 - Improved Parameter request
                 - Add links and solution to errors
    - 2023-05-04 - Anonymous telemetry capture
    - 2023-05-24 - Improved Browser Proxy detection (Added Proxy script option)
                 - Adding additional URLs from https://learn.microsoft.com/en-us/azure/synapse-analytics/security/how-to-connect-to-workspace-from-restricted-network#step-6-allow-url-through-firewall
                 - Small fixes and improvements
    - 2023-05-29 - Documented and improved using GitHub Copilot chatbot
    - 2023-06-21 - Some small fixes
                 - Removed public DNS check. Many CX have blocked internet and requestes were failing and causing confusion
    - 2023-06-22 - Added DB name parameters for dedicated and serverless for connection test
                 - Moved script to official github repo - Version 1.0

# KNOW ISSUES / TO DO
    - Need to make / test on linux / Mac machines
    - Sign code