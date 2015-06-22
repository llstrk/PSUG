<#
.SYNOPSIS
    Finds objects in an Active Directory
.DESCRIPTION
    Takes either an LDAP filter or a direct LDAP path, to return a DirectoryEntry for the object.
.EXAMPLE
    Find-ADObject -DomainFQDN 'contoso.com' -LDAPFilter 'sAMAccountName=John'
.EXAMPLE
    Find-ADObject -DomainFQDN 'contoso.com' -LDAPFilter 'sAMAccountName=John' -OUPath 'OU=MyUsers,DC=contoso,DC=com'
.EXAMPLE
    Find-ADObject -LDAPPath 'CN=John,OU=MyUsers,DC=contoso,DC=com'
#>
function Find-ADObject {
    [Cmdletbinding()]
    param (
        [Parameter(ParameterSetName='LDAPFilter')]
        [string]
        # Fully Qualified Domain name for the domain to retrieve the object from.
        $DomainFQDN=$env:USERDNSDOMAIN,

        [Parameter(ParameterSetName='LDAPFilter')]
        [string]
        # Optional. Path to search in.
        $OUPath,

        [Parameter(Mandatory=$true,
                   ParameterSetName='LDAPFilter')]
        [string]
        # LDAP filter to use when searching for the object.
        $LDAPFilter,

        [Parameter(Mandatory=$true,
                   ParameterSetName='LDAPPath')]
        [string]
        # LDAP path to retrieve DirectoryEntry for.
        $LDAPPath
    )

    if ($PSCmdlet.ParameterSetName -eq 'LDAPFilter') {  
        $domainLdapPath = Resolve-FQDN -Value $DomainFQDN

        if ($OUPath -ne $null -and $OUPath -ne '') {
            if ($OUPath -notlike 'LDAP://*') {
                $domainLdapPath = "LDAP://$OUPath"
            }
            else {
                $domainLdapPath = $OUPath
            }
        }

        $searcher = [adsisearcher]$LDAPFilter
        $domain = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $domainLdapPath
        $searcher.SearchRoot = $domain

        $results = $searcher.FindAll()
        foreach ($result in $results) {
            $result.GetDirectoryEntry()
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'LDAPPath') {
        if ($LDAPPath -notlike 'LDAP://*') {
            $LDAPPath = "LDAP://$LDAPPath"
        }
        New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $LDAPPath
    }
    else {
        Write-Error "Unknown ParameterSetName '$($PSCmdlet.ParameterSetName)'"
    }
}