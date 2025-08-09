# Import-Module Posh-SSH
$InformationPreference = 'Continue'

$data = Import-PowerShellDataFile -Path './data.psd1'

Get-SSHSession | Remove-SSHSession

foreach ($server in $data.Servers) {
    $Password = ConvertTo-SecureString $server.Password -AsPlainText -Force
    $CredentialServer = New-Object System.Management.Automation.PSCredential (
        $server.User, 
        $Password
    )
    New-SSHSession -ComputerName $server.IP -Credential $CredentialServer -Verbose
    New-SFTPSession -ComputerName $server.IP -Credential $CredentialServer -Verbose
}
# uname -a
Invoke-SSHCommand -Command "hostname" -SessionId 0, 1
# Get-SFTPChildItem -SessionId 0, 1
# Get-SFTPContent -SessionId 0, 1 -Path  /etc/shells
Set-SFTPItem -SessionId 0 -Destination /tmp -Path ./README.md -Force
