[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$PullServerSharePath,

    [Parameter(Mandatory=$true)]
    [string]$CsvFile,

    [Parameter(Mandatory=$true)]
    [string]$ConfigurationPath
)

$mofPath           = Join-Path $PullServerSharePath 'MofTemp'
$dscPath           = $PullServerSharePath

Write-Verbose "Importing OU list from $CsvFile"
$clientCsv = Import-Csv $CsvFile -Delimiter ';'

foreach($entry in $clientCsv) {
    Write-Verbose ('Loading configuration {0}' -f $entry.ConfigurationName)
    . ("$ConfigurationPath\{0}.ps1" -f $entry.ConfigurationName)
    
    Write-Verbose ("Getting AD computers from OU '{0}'" -f $entry.OU)
    $computers = @(Get-ADComputer -SearchBase $entry.OU -LDAPFilter "(objectClass=computer)" -SearchScope OneLevel -Properties 'Name','ObjectGuid')
    Write-Verbose ('Found {0} computer objects' -f $computers.Count)


    foreach($computer in $computers) {
        Write-Verbose ('Now processing (computer.Name: {0}, computer.ObjectGuid: {1})' -f $computer.Name, $computer.ObjectGuid)

        $params = @{
            ComputerName = $computer.Name
            OutputPath = Join-Path $mofPath "ClientConfiguration"
        }

        Write-Verbose ('Invoking {0} for {1}' -f $entry.ConfigurationName, $computer.Name)
        $item = Invoke-Expression "$($entry.ConfigurationName) @params"

        $mofDestination = Join-Path $dscPath "$($computer.ObjectGuid).mof"
        Write-Verbose "Copying MOF to $mofDestination"
        $item | Copy-Item -Destination $mofDestination -Force

        # Write nice output
        New-Object -TypeName PSObject -Property @{ComputerName = $computer.Name; ConfigurationName = $entry.ConfigurationName} | Select ComputerName, ConfigurationName
    }
}

Write-Verbose 'Generating checksums...'
New-DSCCheckSum -ConfigurationPath $dscPath -Force