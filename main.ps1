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
# Get-SFTPChildItem -SessionId 0, 1
# Get-SFTPContent -SessionId 0, 1 -Path  /etc/shells

# Set-SFTPItem -SessionId 0 -Destination /tmp -Path ./read_temp.py -Force
Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_temp.py" -SessionId 0
$temp = Invoke-SSHCommand -Command "/tmp/read_temp.py" -SessionId 0
$temp.Output
