param (
    [GUID]$Guid,

    [Parameter(Mandatory=$true)]
    [string]$PullServerUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$LocalConfigPath

    )

if ($Guid -eq $null) {
    try {
        [GUID]$Guid = ([guid]([adsisearcher]"(samaccountname=$env:ComputerName`$)").FindOne().Properties["objectguid"][0])
    }
    catch {}
}

function WriteError($eventId) {
    $logName   = "System"
    $logSource = "SYSTEMHOSTING-DSC"
    $msg       = "Unknown error"
    $type      = "Error"

    switch ($eventId) {
        10001 {
            $msg  = "Unable to configure DSC for pull mode, could not find a GUID for $env:computername in Active Directory."
            $type = "Error"
        }
        10002 {
            $msg  = "Unable to run Set-DscLocalConfigurationManager."
            $type = "Error"
        }
        10003 {
            $msg  = "Unable to find LocalConfigPath ($($LocalConfigPath))."
            $type = "Error"
        }
    }

    if (! (Get-EventLog -LogName $logName -Source $logSource -Newest 1 -ErrorAction SilentlyContinue) ) {
        New-EventLog -LogName $logName -Source $logSource
    }

    Write-EventLog -LogName $logName -Message $msg -Source $logSource -EventId $eventId -EntryType $type
}

Configuration SetPullMode 
{
	param (
        [string[]]$ComputerName="localhost",
        [string]$PullServer,
        [string]$Guid
    )
	Node $ComputerName
	{
		LocalConfigurationManager
		{
            AllowModuleOverwrite      = 'True'
			ConfigurationMode         = 'ApplyAndAutoCorrect'
			ConfigurationID           = $Guid
			RefreshMode               = 'Pull'
			DownloadManagerName       = 'WebDownloadManager'
			DownloadManagerCustomData = @{
				ServerUrl = $PullServer;
                AllowUnsecureConnection = 'true' }
		}
	}
}

if (-not (Test-Path $LocalConfigPath)) {
    WriteError 10003
}

if ($Guid -ne $null) {
    SetPullMode -Guid $Guid.Guid -PullServer $PullServerUrl -OutputPath $LocalConfigPath | Out-Null
    Set-DscLocalConfigurationManager -Path $LocalConfigPath -ErrorVariable ProcessError -ErrorAction Continue

    if ($ProcessError) {
        WriteError 10002
    }
}
else {
    WriteError 10001
}