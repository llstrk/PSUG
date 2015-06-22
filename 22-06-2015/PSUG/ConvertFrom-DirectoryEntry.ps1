<#
.SYNOPSIS
    Converts a DirectoryEntry into a PSObject.

.DESCRIPTION
    Takes a DirectoryEntry and converts it into a usable PSObject.

.EXAMPLE
    Find-ADObject -LDAPFilter "(&(objectClass=user)(sAMAccountName=johndoe))" | ConvertFrom-DirectoryEntry

#>
function ConvertFrom-DirectoryEntry {
    [Cmdletbinding()]
    param (
        # DirectoryEntry object to convert into a PSObject.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.DirectoryServices.DirectoryEntry]$InputObject
    )

    Process {
        $obj = New-Object -TypeName PSObject

        foreach ($property in (Get-Member -InputObject $InputObject -MemberType Property)) {
            $obj | Add-Member -MemberType NoteProperty -Name $property.Name -Value $InputObject."$($property.Name)".Value
        }

        $obj
    }
}