function Block-NoInternet {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Warn,
        [System.Management.Automation.SwitchParameter]$Pause
    )
    $CallingFunction = (Get-PSCallStack)[1].InvocationInfo.Line
    $Message = "[$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))] $CallingFunction requires Internet access"
    
    $TestURLs = @('google.com','github.com','nvidia.com','apple.com')
    
    foreach ($URL in $TestURLs){
        if (Test-WebConnection -Uri $URL){
            $Success = $true
            break
        }
        else {
            $Success = $false
        }
    }   
    if ($Success -eq $false) {
        Write-Warning $Message
        if ($PSBoundParameters.ContainsKey('Pause')) {
            [void]('Press Enter to Continue')
        }
        if (-NOT ($PSBoundParameters.ContainsKey('Warn'))) {
            Break
        }
    }
}