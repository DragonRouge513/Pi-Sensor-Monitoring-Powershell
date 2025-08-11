# Import-Module Posh-SSH
$InformationPreference = 'Continue'
Clear-Host

$data = Import-PowerShellDataFile -Path './data.psd1'
# Dot-source the scripts
. "$PSScriptRoot./screen.ps1"
. "$PSScriptRoot./database.ps1"

$data = Import-PowerShellDataFile -Path './data.psd1'
Get-SSHSession | Remove-SSHSession
Get-Job | Stop-Job -ErrorAction SilentlyContinue
Get-Job | Remove-Job -Force -ErrorAction SilentlyContinue
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
    Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./read_compass.py -Force
    Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./led_matrix.py -Force
    Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./led_matrix_clear.py -Force
    # Set-SFTPItem -SessionId $sftpSessionId -Destination /tmp -Path ./read_gpio.py -Force

    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_temp.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_hum.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_pres.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_compass.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/led_matrix.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/led_matrix_clear.py" -SessionId $sshSessionId
    # Invoke-SSHCommand -Command "sed -i 's/\r$//' /tmp/read_gpio.py" -SessionId $sshSessionId

    Invoke-SSHCommand -Command "chmod +x /tmp/read_temp.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "chmod +x /tmp/read_hum.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "chmod +x /tmp/read_pres.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "chmod +x /tmp/read_compass.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "chmod +x /tmp/led_matrix.py" -SessionId $sshSessionId
    Invoke-SSHCommand -Command "chmod +x /tmp/led_matrix_clear.py" -SessionId $sshSessionId
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
    $form = Set-Form -formText "Pi-Sensor-Monitoring-Powershell" -formWidth 800 -formHeight 1000

    # Add menu for changing Pi data using helper from screen.ps1

    $tabControl = Add-TabControl -parentControl $form -tabControlWidth 750 -tabControlHeight 800 -tabControlLocationX 10 -tabControlLocationY 40
    $tabsPi = @()
    $tables = @{}
    # $charts = @{}
    $warningLabels = @{}

    foreach ($server in $data.Servers) {
        $tab = Add-tabPage -tabControl $tabControl -tabText $server.Hostname
        $tabsPi += $tab

        # Create sub-tab control for SenseHat and GPIO
        $subTabControl = Add-TabControl -parentControl $tab -tabControlWidth 730 -tabControlHeight 600 -tabControlLocationX 5 -tabControlLocationY 5
        # SenseHat sub-tab
        $senseHatTab = Add-tabPage -tabControl $subTabControl -tabText "SenseHat"

        # Table for SenseHat
        $senseHatTable = Add-Table -parentControl $senseHatTab -tableWidth 700 -tableHeight 300 -tableLocationX 10 -tableLocationY 10
        # Initialize table with placeholder data so it's always visible
        $placeholderData = @(
            @("Row", "Sensor", "Value"),
            @("1", "Temp", "-"),
            @("2", "Humidity", "-"),
            @("3", "Pressure", "-"),
            @("4", "MagX", "-"),
            @("5", "MagY", "-"),
            @("6", "MagZ", "-")
        )
        Set-Table -table $senseHatTable -data $placeholderData -highlightPin ""

        $senseHatWarningLabel = Add-Label -parentControl $senseHatTab -labelText "" -labelLocationX 10 -labelLocationY 350 -labelWidth 700 -labelHeight 40
        $senseHatWarningLabel.Visible = $false

        $button = Add-Button -parentControl $senseHatTab -buttonText "view led" -buttonLocationX 10 -buttonLocationY 450 -buttonHeight 40 -buttonWidth 100
        $button.Add_Click({
                [System.Windows.Forms.MessageBox]::Show("Button clicked! You can add your action here.")
                Invoke-SSHCommand -Command "/tmp/led_matrix.py" -SessionId 0, 1, 2, 3
            })
        $button = Add-Button -parentControl $senseHatTab -buttonText "clear led" -buttonLocationX 50 -buttonLocationY 450 -buttonHeight 40 -buttonWidth 100
        $button.Add_Click({
                [System.Windows.Forms.MessageBox]::Show("Button clicked! You can add your action here.")
                Invoke-SSHCommand -Command "/tmp/led_matrix_clear.py" -SessionId 0, 1, 2, 3
            })

        # Store references for later updates (only initialized objects)
        $tables[$server.Hostname] = @{ Main = $senseHatTable }
        $warningLabels[$server.Hostname] = $senseHatWarningLabel
    }


    # UI update timer: only reads from DB and updates UI

    $uiTimer = New-Object System.Windows.Forms.Timer
    $uiTimer.Interval = 2000 # ms, same as background thread
    $uiTimer.Add_Tick({
            $limits = $data.Limits
            foreach ($server in $data.Servers) {
                $hostname = $server.Hostname
                $existingPi = Invoke-SQLiteQuery -Connection $conn -Query "SELECT PiId FROM Pi WHERE Hostname = @Hostname;" -SqlParameters @{Hostname = $hostname }
                if ($existingPi) {
                    $dbPiId = $existingPi.PiId | Select-Object -First 1
                    # Only use the latest SenseHat record for this Pi
                    $sense = Invoke-SQLiteQuery -Connection $conn -Query "SELECT * FROM SenseHat WHERE PiId = @PiId ORDER BY Timestamp DESC LIMIT 1;" -SqlParameters @{PiId = $dbPiId }
                    if ($sense) {
                        $tempValue = $sense.Temperature
                        $humValue = $sense.Humidity
                        $presValue = $sense.Pressure
                        $minTemp = $limits.Temp.Min
                        $maxTemp = $limits.Temp.Max
                        $minHum = $limits.Hum.Min
                        $maxHum = $limits.Hum.Max
                        $minPres = $limits.Pres.Min
                        $maxPres = $limits.Pres.Max
                        $warningText = @()
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
                        $warningLabel = $warningLabels[$hostname]
                        if ($tempValue -eq 0 -and $humValue -eq 0 -and $presValue -eq 0) {
                            $warningLabel.Text = ""
                            $warningLabel.Visible = $false
                        }
                        else {
                            if ($hasWarning) {
                                $warningLabel.Text = [string]::Join(" ", $warningText)
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
                            @("3", "Pressure", $presValue),
                            @("4", "MagX", $sense.MagX),
                            @("5", "MagY", $sense.MagY),
                            @("6", "MagZ", $sense.MagZ)
                        )
                        Set-Table -table $tables[$hostname].Main -data $tableData -highlightPin ""
                    }
                }
            }
        })
    $uiTimer.Start()

    # Stop and dispose timer on form closing
    $form.Add_FormClosing({
            $uiTimer.Stop()
            $uiTimer.Dispose()
        })

    $form.ShowDialog()
}

# Background job: fetches sensor data and writes to DB
Start-Job -Name "SensorFetcherJob" -ScriptBlock {
    try {
        Import-Module Posh-SSH
        Import-Module PSSQLite
        # Ensure working directory is correct
        Set-Location -Path $using:PSScriptRoot
        $data = Import-PowerShellDataFile -Path './data.psd1'
        $database = "./Sensor.db"
        $conn = New-SQLiteConnection -DataSource $database
        function Add-Pi {
            param([string]$Hostname, [string]$Location)
            $query = "INSERT INTO Pi (Hostname, Location) VALUES (@Hostname, @Location);"
            $params = @{ Hostname = $Hostname; Location = $Location }
            Invoke-SQLiteQuery -Connection $conn -Query $query -SqlParameters $params
        }
        function Add-SenseHat {
            param(
                [int]$PiId,
                [double]$Temperature,
                [double]$Humidity,
                [double]$Pressure,
                [double]$OrientationPitch,
                [double]$OrientationRoll,
                [double]$OrientationYaw,
                [double]$AccelX,
                [double]$AccelY,
                [double]$AccelZ,
                [double]$MagX,
                [double]$MagY,
                [double]$MagZ
            )
            $query = @"
INSERT INTO SenseHat (
    PiId, Temperature, Humidity, Pressure, OrientationPitch, OrientationRoll, OrientationYaw,
    AccelX, AccelY, AccelZ, MagX, MagY, MagZ
) VALUES (
    @PiId, @Temperature, @Humidity, @Pressure, @OrientationPitch, @OrientationRoll, @OrientationYaw,
    @AccelX, @AccelY, @AccelZ, @MagX, @MagY, @MagZ
);
"@
            $params = @{ PiId = $PiId; Temperature = $Temperature; Humidity = $Humidity; Pressure = $Pressure;
                OrientationPitch = $OrientationPitch; OrientationRoll = $OrientationRoll; OrientationYaw = $OrientationYaw;
                AccelX = $AccelX; AccelY = $AccelY; AccelZ = $AccelZ; MagX = $MagX; MagY = $MagY; MagZ = $MagZ 
            }
            Invoke-SQLiteQuery -Connection $conn -Query $query -SqlParameters $params
        }
        while ($true) {
            foreach ($server in $data.Servers) {
                $Password = ConvertTo-SecureString $server.Password -AsPlainText -Force
                $CredentialServer = New-Object System.Management.Automation.PSCredential ($server.User, $Password)
                $sshSession = New-SSHSession -ComputerName $server.IP -Credential $CredentialServer -Verbose
                $sshSessionId = $sshSession.SessionId
                $temp = Invoke-SSHCommand -Command "/tmp/read_temp.py" -SessionId $sshSessionId
                $hum = Invoke-SSHCommand -Command "/tmp/read_hum.py" -SessionId $sshSessionId
                $pres = Invoke-SSHCommand -Command "/tmp/read_pres.py" -SessionId $sshSessionId
                $compas = Invoke-SSHCommand -Command "/tmp/read_compass.py" -SessionId $sshSessionId
                $tempValue = [double]($temp.Output | Select-Object -First 1)
                $humValue = [double]($hum.Output | Select-Object -First 1)
                $presValue = [double]($pres.Output | Select-Object -First 1)
                $compasOutput = ($compas.Output | Select-Object -First 1)
                $compasParts = $compasOutput -split '\s+'
                $compasValueX = [double]$compasParts[0]
                $compasValueY = [double]$compasParts[1]
                $compasValueZ = [double]$compasParts[2]
                $existingPi = Invoke-SQLiteQuery -Connection $conn -Query "SELECT PiId FROM Pi WHERE Hostname = @Hostname;" -SqlParameters @{Hostname = $server.Hostname }
                if (-not $existingPi) {
                    Add-Pi -Hostname $server.Hostname -Location "Unknown"
                    $dbPiId = (Invoke-SQLiteQuery -Connection $conn -Query "SELECT PiId FROM Pi WHERE Hostname = @Hostname;" -SqlParameters @{Hostname = $server.Hostname }).PiId | Select-Object -First 1
                }
                else {
                    $dbPiId = $existingPi.PiId | Select-Object -First 1
                }
                Add-SenseHat -PiId $dbPiId -Temperature $tempValue -Humidity $humValue -Pressure $presValue `
                    -OrientationPitch 0 -OrientationRoll 0 -OrientationYaw 0 `
                    -AccelX 0 -AccelY 0 -AccelZ 0 `
                    -MagX $compasValueX -MagY $compasValueY -MagZ $compasValueZ
                Remove-SSHSession -SessionId $sshSessionId
            }
            Start-Sleep -Seconds 2
        }
    }
    catch {
        # Log error to a file for debugging
        $_ | Out-File -FilePath "$env:TEMP\SensorFetcherJob_error.log" -Append
    }
}
# Output job status for debugging
Start-Sleep -Seconds 1
Get-Job -Name "SensorFetcherJob" | Format-Table Id, Name, State
# Load the configuration file
# $config = Get-Content "$PSScriptRoot/ipConfig.json" | ConvertFrom-Json

Start-Screen