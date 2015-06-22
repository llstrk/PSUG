$files = Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1'

foreach ($file in $files) {
    Write-Verbose "Loading '$($file.Name)'."
    . $file.FullName
}

Export-ModuleMember -Function '*'