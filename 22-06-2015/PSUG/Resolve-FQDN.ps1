<#
.SYNOPSIS
    Resolves a FQDN into an LDAP path
.EXAMPLE
    Resolve-FQDN -Value test.contoso.com
    LDAP://DC=test,DC=contoso,DC=com
#>
function Resolve-FQDN {
    [Cmdletbinding()]
    param (
        # Fully Qualified Domain Name that needs to be resolved into an LDAP path.
        [Parameter(Mandatory=$true)]
        [string]$Value
    )

    $split = @($Value -split '\.')
    $ldapPath = 'LDAP://'

    foreach ($s in $split) {
        $ldapPath += ("DC={0}," -f $s)
    }

    if ($ldapPath[$ldapPath.Length-1] -eq ',') {
        $ldapPath = $ldapPath.Substring(0, $ldapPath.Length-1)
    }

    $ldapPath
}