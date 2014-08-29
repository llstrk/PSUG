Configuration StandardConfiguration {
    param(
        [Parameter(Mandatory)]
        $ComputerName
    )

    Import-DscResource -ModuleName cRDPEnabled

    Node $ComputerName {
        cRDPEnabled RDP {
            Enabled                   = $true
            NLARequired               = $true
            EnableDefaultFirewallRule = $true

        }
    }
}