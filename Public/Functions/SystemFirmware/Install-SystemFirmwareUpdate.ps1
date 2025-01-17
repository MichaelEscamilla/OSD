function Install-SystemFirmwareUpdate {
    [CmdLetBinding()]
    param (
        [String] $DestinationDirectory = "C:\Drivers\SystemFirmwareUpdate"
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-StandardUser
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck -ErrorAction Ignore
    }
    #=================================================
    if (Test-Path 'C:\Windows' -PathType Container) {
        if (Test-MicrosoftUpdateCatalog) {
            if (Get-Module -ListAvailable -Name MSCatalog -ErrorAction Ignore) {
                $SystemFirmwareUpdate = Get-SystemFirmwareUpdate
            
                if ($SystemFirmwareUpdate.Guid) {
                    Write-Host -ForegroundColor DarkGray "$($SystemFirmwareUpdate.Title) version $($SystemFirmwareUpdate.Version)"
                    Write-Host -ForegroundColor DarkGray "Version $($SystemFirmwareUpdate.Version) Size: $($SystemFirmwareUpdate.Size)"
                    Write-Host -ForegroundColor DarkGray "Last Updated $($SystemFirmwareUpdate.LastUpdated)"
                    Write-Host -ForegroundColor DarkGray "UpdateID: $($SystemFirmwareUpdate.Guid)"
                    Write-Host -ForegroundColor DarkGray ""
                }
            
                if ($SystemFirmwareUpdate) {
                    $SystemFirmwareUpdateFile = Save-UpdateCatalog -Guid $SystemFirmwareUpdate.Guid -DestinationDirectory $DestinationDirectory
                    if ($SystemFirmwareUpdateFile) {
                        expand.exe "$($SystemFirmwareUpdateFile.FullName)" -F:* "$DestinationDirectory"
                        Remove-Item $SystemFirmwareUpdateFile.FullName | Out-Null
                        if ($env:SystemDrive -eq 'X:') {
                            Add-WindowsDriver -Path 'C:\' -Driver "$DestinationDirectory"
                        }
                        else {
                            if (Test-Path "$DestinationDirectory" -PathType Container) {
                                Get-ChildItem "$DestinationDirectory" -Recurse -Filter "*.inf" | ForEach-Object { PNPUtil.exe /Add-Driver $_.FullName /install }
                            }
                        }
                    }
                    else {
                        Write-Warning "Install-SystemFirmwareUpdate: Could not find a UEFI Firmware update for this HardwareID"
                    }
                }
                else {
                    Write-Warning "Install-SystemFirmwareUpdate: Could not find a UEFI Firmware HardwareID"
                }
            }
            else {
                Write-Warning "Install-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
            }
        }
        else {
            Write-Warning "Install-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
        }
    }
    else {
        Write-Warning "Install-SystemFirmwareUpdate: Could not locate C:\Windows"
        if ($env:SystemDrive -eq 'X:') {
            Write-Warning "Make sure that Bitlocker encrypted drives are unlocked and suspended first"
        }
    }
    #=================================================
}
