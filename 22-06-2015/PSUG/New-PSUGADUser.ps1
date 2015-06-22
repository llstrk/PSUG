Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'

function New-PSUGADUser {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ $_.IndexOf('@') -gt 0 })]
        [string]$UserPrincipalName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FirstName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$LastName,

        [Parameter(Mandatory)]
        [string]$OUPath
    )
    
    Begin {
        $ou = Find-ADObject -LDAPPath $OUPath
    }
    Process {    
        $sAMAccountName = $UserPrincipalName.Substring(0, $UserPrincipalName.IndexOf('@'))
        
        $newUser = $ou.Create('user',"CN=$($FirstName) $($LastName)")
        $newUser.Put('UserAccountControl', 514)
        $newUser.Put('givenName', $FirstName)
        $newUser.Put('sn', $LastName)
        $newUser.Put('sAMAccountName', $SAMAccountName)
        $newUser.Put('userPrincipalName', $UserPrincipalName)
    
        $newUser.SetInfo()
    }
}