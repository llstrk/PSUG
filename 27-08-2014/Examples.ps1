### Pull Server Configuration ###
# This script will configure the machine that it is run on as a pull server, with the necessary SMB shares. Assumes C:\DSC exists and is writeable.
# You need to put the cRDPEnabled_1.1.2.zip and \cRDPEnabled_1.1.2.zip.checksum files (located the Module folder) into C:\Program Files\WindowsPowerShell\DscService\Modules after the Pull Server has been installed.
.\Configuration\PullServerConfiguration.ps1

### DSC Pull Configuration ###
# The following example will configure the machine it is run on as a DSC pull client, using the PullServerUrl specified. The local config will be stored in the path specified for LocalConfigPath
# It's also possible to assign a GUID with -Guid. If no GUID is assigned, the script will try to get the computer objects objectGUID from Active Directory.
# This is the script that we use to configure our clients for DSC through a scheduled task in a group policy.
.\Tools\Set-DscPullConfiguration.ps1 -PullServerUrl 'http://dscpull01.dry.systemhosting.dk:8080/DSCWebService/PSDSCPullServer.svc' -LocalConfigPath 'C:\DSC'

### Generate DSC Configurations ###
# Generates configs from Active Directory OUs, based on -CsvFile and -ConfigurationPath. Assumes that the -PullServerSharePath contains the folder MofTemp.
# On the computer that runs this script, you need to install the cRDPEnabled DSC resource, by copying it from the Module folder to C:\Program Files\WindowsPowerShell\Modules
.\Tools\Invoke-DscConfigurationFromActiveDirectory.ps1 -PullServerSharePath '\\dscpull01\DSCConfig' -CsvFile .\Configuration\DscConfigurationOUList.csv -ConfigurationPath .\Configuration

### Force DSC Pull Client To Update ###
# This script will trigger DSC to check the Pull Server for a new configuration, and apply it if there's one.
.\Tools\Invoke-ConsistencyCheck.ps1 -ComputerName Server01