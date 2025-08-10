# Import-Module Posh-SSH
$InformationPreference = 'Continue'
Clear-Host

$data = Import-PowerShellDataFile -Path './data.psd1'
# Dot-source the scripts
. "$PSScriptRoot./screen.ps1"
. "$PSScriptRoot./database.ps1"

Get-SSHSession | Remove-SSHSession
Clear-Database

foreach ($server in $data.Servers) {
    $Password = ConvertTo-SecureString $server.Password -AsPlainText -Force
    $CredentialServer = New-Object System.Management.Automation.PSCredential (
        $server.User, 
        $Password
    )
    $sshSession = New-SSHSession -ComputerName $server.IP -Credential $CredentialServer -Verbose
    $sftpSession = New-SFTPSession -ComputerName $server.IP -Credential $CredentialServer -Verbose

    # Use the session ID for each server
    $sshSessionId = $sshSession.SessionId
    $sftpSessionId = $sftpSession.SessionId

    Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./read_temp.py -Force
    Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./read_hum.py -Force
    Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./read_pres.py -Force
    # Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./read_gpio.py -Force

    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_temp.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_hum.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_pres.py" -SessionId $sshSessionId
    # Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_gpio.py" -SessionId $sshSessionId

    Invoke-SSHCommand -Command "chmod +x /tmp/read_temp.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "chmod +x /tmp/read_hum.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "chmod +x /tmp/read_pres.py" -SessionId $sshSessionId
    # Invoke-SSHCommand -Command "chmod +x /tmp/read_gpio.py" -SessionId $sshSessionId

    # Invoke-SSHCommand -Command "python3 -m venv myenv" -SessionId $sshSessionId
    # Invoke-SSHCommand -Command "source myenv/bin/activate" -SessionId $sshSessionId
    # Invoke-SSHCommand -Command "pip install RPi.GPIO" -SessionId $sshSessionId
    
}

#region GUI
<#
.SYNOPSIS
    Starts the main screen for the Pi-Sensor-Monitoring-Powershell application.
#>
function Start-Screen {
    $form = Set-Form -formText "Pi-Sensor-Monitoring-Powershell" -formWidth 800 -formHeight 800

    # Add menu for changing Pi data using helper from screen.ps1

    $tabControl = Add-TabControl -parentControl $form -tabControlWidth 750 -tabControlHeight 600 -tabControlLocationX 10 -tabControlLocationY 40
    $tabsPi = @()
    $tables = @{}
    $charts = @{}
    $warningLabels = @{}

    foreach ($server in $data.Servers) {
        $tab = Add-tabPage -tabControl $tabControl -tabText $server.Hostname
        $tabsPi += $tab

        # Create sub-tab control for SenseHat and GPIO
        $subTabControl = Add-TabControl -parentControl $tab -tabControlWidth 730 -tabControlHeight 500 -tabControlLocationX 5 -tabControlLocationY 5

        # SenseHat sub-tab
        $senseHatTab = Add-tabPage -tabControl $subTabControl -tabText "SenseHat"
        # Table and chart for SenseHat
        $senseHatTable = Add-Table -parentControl $senseHatTab -tableWidth 700 -tableHeight 300 -tableLocationX 10 -tableLocationY 10
        # $senseHatChart = Add-Chart -parentControl $senseHatTab -chartWidth 350 -chartHeight 200 -chartLocationX 370 -chartLocationY 10
        $senseHatWarningLabel = Add-Label -parentControl $senseHatTab -labelText "" -labelLocationX 10 -labelLocationY 350 -labelWidth 700 -labelHeight 40
        $senseHatWarningLabel.Visible = $false

        # GPIO sub-tab
        # $gpioTab = Add-tabPage -tabControl $subTabControl -tabText "GPIO"
        # Table and chart for GPIO
        # $gpioTable = Add-Table -parentControl $gpioTab -tableWidth 700 -tableHeight 300 -tableLocationX 10 -tableLocationY 10
        # $gpioChart = Add-Chart -parentControl $gpioTab -chartWidth 350 -chartHeight 200 -chartLocationX 370 -chartLocationY 10

        # Store references for later updates
        $tables[$server.Hostname] = @{ Main = $senseHatTable; GPIO = $gpioTable }
        $charts[$server.Hostname] = @{ Main = $senseHatChart; GPIO = $gpioChart }
        $warningLabels[$server.Hostname] = $senseHatWarningLabel
    }

    # Timer for dynamic updates
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 2000 # ms, adjust as needed

    $timer.Add_Tick({
            if (-not $script:warnedTemp) { $script:warnedTemp = @{} }
            if (-not $script:warnedHum) { $script:warnedHum = @{} }
            foreach ($server in $data.Servers) {
                # Find the session for this server
                $sshSession = Get-SSHSession | Where-Object { $_.Host -eq $server.IP }
                if ($sshSession) {
                    $sessionId = $sshSession.SessionId
                    $temp = Invoke-SSHCommand -Command "/tmp/read_temp.py" -SessionId $sessionId
                    $hum = Invoke-SSHCommand -Command "/tmp/read_hum.py" -SessionId $sessionId
                    $pres = Invoke-SSHCommand -Command "/tmp/read_pres.py" -SessionId $sessionId
                    # $gpio = Invoke-SSHCommand -Command "python3 /tmp/read_gpio.py" -SessionId $sessionId

                    # Write-Information $gpio

                    $tempValue = [double]($temp.Output | Select-Object -First 1)
                    $humValue = [double]($hum.Output | Select-Object -First 1)
                    $presValue = [double]($pres.Output | Select-Object -First 1)
                    # Notification system for out-of-range values using label
                    # Notification system for out-of-range values using label
                    $minTemp = 10
                    $maxTemp = 35
                    $minHum = 20
                    $maxHum = 80
                    $maxPres = 1030
                    $minPres = 990
                    $warningText = @()  # Use an array to collect warning messages
                    $hasWarning = $false

                    if ($tempValue -lt $minTemp -or $tempValue -gt $maxTemp) {
                        $warningText += "Temperature ($tempValue°C) is out of range."
                        $hasWarning = $true
                    }
                    if ($humValue -lt $minHum -or $humValue -gt $maxHum) {
                        $warningText += "Humidity ($humValue%) is out of range."
                        $hasWarning = $true
                    }
                    if ($presValue -lt $minPres -or $presValue -gt $maxPres) {
                        $warningText += "Pressure ($presValue hPa) is out of range."
                        $hasWarning = $true
                    }

                    $warningLabel = $warningLabels[$server.Hostname]
                    if ($tempValue -eq 0 -and $humValue -eq 0 -and $presValue -eq 0) {
                        $warningLabel.Text = ""
                        $warningLabel.Visible = $false
                    }
                    else {
                        if ($hasWarning) {
                            $warningLabel.Text = [string]::Join(" ", $warningText)  # Join the warning messages into a single string
                            $warningLabel.Visible = $true
                        }
                        else {
                            $warningLabel.Text = ""
                            $warningLabel.Visible = $false
                        }
                    }
                    $tableData = @(
                        @("Row", "Sensor", "Value"),
                        @("1", "Temp", $tempValue),
                        @("2", "Humidity", $humValue),
                        @("3", "Pressure", $presValue)
                    )
                    Set-Table -table $tables[$server.Hostname].Main -data $tableData -highlightPin ""

                    # Save to SENSEHAT_SENSOR table
                    $existingPi = Invoke-SQLiteQuery -Connection $conn -Query "SELECT PiId FROM Pi WHERE Hostname = @Hostname;" -SqlParameters @{Hostname = $server.Hostname }
                    if (-not $existingPi) {
                        Add-Pi -Hostname $server.Hostname -Location "Unknown"
                        $dbPiId = (Invoke-SQLiteQuery -Connection $conn -Query "SELECT PiId FROM Pi WHERE Hostname = @Hostname;" -SqlParameters @{Hostname = $server.Hostname }).PiId | Select-Object -First 1
                    }
                    else {
                        $dbPiId = $existingPi.PiId | Select-Object -First 1
                    }
                    # Save temperature and humidity to SenseHat table
                    Add-SenseHat -PiId $dbPiId -Temperature $tempValue -Humidity $humValue -Pressure $presValue -OrientationPitch 0 -OrientationRoll 0 -OrientationYaw 0 -AccelX 0 -AccelY 0 -AccelZ 0 -MagX 0 -MagY 0 -MagZ 0
                }
            }
        })
    $timer.Start()
    
    # Stop and dispose timer on form closing
    $form.Add_FormClosing({
            $timer.Stop()
            $timer.Dispose()
        })

    $form.ShowDialog()
}

# Load the configuration file
# $config = Get-Content "$PSScriptRoot/ipConfig.json" | ConvertFrom-Json

Start-Screen