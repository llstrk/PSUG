$username = "newuser"

$ou = [ADSI]"LDAP://OU=Users,DC=domain,DC=local"

$newUser = $ou.Create('user', "CN=$username")
$newUser.Put('sAMAccountName', $username)

$newUser.SetInfo()

$newUser = [ADSI]"LDAP://CN=$username,OU=Users,DC=domain,DC=local"

$newUser.Properties.Description.Value = "New user account"