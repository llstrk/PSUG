function Set-PSUGADUserProperty {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName="SAMAccountName")]
        [string]
        $SAMAccountName,

        [Parameter(ParameterSetName="SAMAccountName")]
        [string]
        $DomainFQDN=$env:USERDNSDOMAIN,

        [Parameter(Mandatory,
                   ValueFromPipeline=$true,
                   ParameterSetName="DirectoryEntry")]
        [System.DirectoryServices.DirectoryEntry]
        $DirectoryEntry,

        [Parameter(Mandatory)]
        #[ValidateSet('givenName','sn','description')]
        [string]$PropertyName,

        [Parameter(Mandatory)]
        [string]$PropertyValue
    )
    
    Begin {
        Set-StrictMode -Version 2
        $ErrorActionPreference = 'Stop'
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq 'SAMAccountName') {
            $object = Find-ADObject -DomainFQDN $DomainFQDN -LDAPFilter "(&(objectClass=user)(sAMAccountName=$($SAMAccountName)))"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'DirectoryEntry') {
            $object = Find-ADObject -LDAPPath $DirectoryEntry.Properties.DistinguishedName.Value
        }
        else {
            Write-Error "No input object found."
        }

        $object.Put($PropertyName, $PropertyValue)

        $object.SetInfo()
    }
}