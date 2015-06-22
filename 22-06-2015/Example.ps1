Remove-Module PSUG -ErrorAction SilentlyContinue
Import-Module PSUG

New-PSUGADUser -UserPrincipalName johndoe@demo.psug.dk -FirstName 'John' -LastName 'Doe' -OUPath 'OU=Users,OU=PSUG,DC=demo,DC=psug,DC=dk'

Find-ADObject -DomainFQDN 'demo.psug.dk' -LDAPFilter '(&(objectClass=user)(userPrincipalName=johndoe@demo.psug.dk))' | ConvertFrom-DirectoryEntry | Set-PSUGADUserProperty -PropertyName description -PropertyValue 'Description with SAMAccountName'

Find-ADObject -DomainFQDN 'demo.psug.dk' -LDAPFilter '(&(objectClass=user)(userPrincipalName=johndoe@demo.psug.dk))' | Set-PSUGADUserProperty -PropertyName description -PropertyValue 'Description with DirectoryEntry'



$csv = Import-Csv -Path C:\PSUG\testusers.csv

$csv | New-PSUGADUser -OUPath 'OU=Users,OU=PSUG,DC=demo,DC=psug,DC=dk'

foreach ($item in $csv) {
    Wait-ADReplication -UPN $item.UserPrincipalName -DomainName 'demo.psug.dk'
}

Find-ADObject -LDAPFilter "sAMAccountName=testuser*" | ConvertFrom-DirectoryEntry | Set-PSUGADUserProperty -PropertyName description -PropertyValue 'Bulk created'