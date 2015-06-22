Remove-Item 'C:\Program Files\WindowsPowerShell\Modules\PSUG' -Confirm:$false -Recurse
copy C:\PSUG\PSUG 'C:\Program Files\WindowsPowerShell\Modules' -Force -Recurse

Remove-Module PSUG -ErrorAction SilentlyContinue
Import-Module PSUG -Verbose