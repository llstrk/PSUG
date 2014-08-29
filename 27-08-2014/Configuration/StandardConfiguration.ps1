Configuration StandardConfiguration {
    param(
        [Parameter(Mandatory)]
        $ComputerName
    )

    Import-DscResource -ModuleName cRDPEnabled

    Node $ComputerName {
        cRDPEnabled RDP {
            Enabled = $false
        }
    }
}