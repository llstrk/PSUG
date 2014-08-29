Configuration PullServerConfiguration {
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xSmbShare

    Node localhost {
        WindowsFeature Net45 {
            Ensure = "Present"
            Name   = "NET-Framework-45-Core"
        }
        WindowsFeature DSCService {
            Ensure    = "Present"
            Name      = "DSC-Service"
            DependsOn = "[WindowsFeature]Net45"
        }

        xDscWebService DSCWebService {
            Ensure                = "Present"
            EndpointName          = "DSCWebService"
            Port                  = "8080"
            CertificateThumbprint = "AllowUnencryptedTraffic"
            PhysicalPath          = "$env:SystemDrive\inetpub\wwwroot\DSCWebService"
            ModulePath            = "$env:ProgramFiles\WindowsPowerShell\DscService\Modules"
            ConfigurationPath     = "$env:ProgramFiles\WindowsPowerShell\DscService\Configuration"
            State                 = "Started"
            DependsOn             = "[WindowsFeature]DSCService"
        }

        xDscWebService DSCWebServiceCompliance {
            Ensure                = "Present"
            EndpointName          = "DSCWebServiceCompliance"
            Port                  = "9080"
            CertificateThumbprint = "AllowUnencryptedTraffic"
            PhysicalPath          = "$env:SystemDrive\inetpub\wwwroot\DSCWebServiceCompliance"
            State                 = "Started"
            DependsOn             = "[xDscWebService]DSCWebService"
            IsComplianceServer    = $true
        }

        xSmbShare DSCConfigShare {
            Ensure     = "Present"
            Name       = "DSCConfig"
            Path       = "$env:ProgramFiles\WindowsPowerShell\DscService\Configuration"
            FullAccess = "DRY\Domain Admins"
            DependsOn  = "[xDscWebService]DSCWebServiceCompliance"
        }
        xSmbShare DSCModulesShare {
            Ensure     = "Present"
            Name       = "DSCModules"
            Path       = "$env:ProgramFiles\WindowsPowerShell\DscService\Modules"
            FullAccess = "DRY\Domain Admins"
            DependsOn  = "[xDscWebService]DSCWebServiceCompliance"
        }
    }
}

PullServerConfiguration -OutputPath C:\DSC\PullServerConfiguration

Start-DscConfiguration -Path C:\DSC\PullServerConfiguration -Wait -Verbose