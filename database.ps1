Import-Module PSSQLite

$database = "./Sensor.db"
$conn = New-SQLiteConnection -DataSource $database
# Create Pi table
$createPiTable = @"
CREATE TABLE IF NOT EXISTS Pi (
	PiId INTEGER PRIMARY KEY AUTOINCREMENT,
	Hostname TEXT,
	Location TEXT,
	CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
"@
Invoke-SQLiteQuery -Connection $conn -Query $createPiTable

# Create GPIO table
$createGPIOTable = @"
CREATE TABLE IF NOT EXISTS GPIO (
	GPIOId INTEGER PRIMARY KEY AUTOINCREMENT,
	PiId INTEGER,
	PinNumber INTEGER,
	Status TEXT,
	Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (PiId) REFERENCES Pi(PiId)
);
"@
Invoke-SQLiteQuery -Connection $conn -Query $createGPIOTable

# Create SenseHat table (add CompassHeading and GyroPitch, GyroRoll, GyroYaw columns)
$createSenseHatTable = @"
CREATE TABLE IF NOT EXISTS SenseHat (
    SenseHatId INTEGER PRIMARY KEY AUTOINCREMENT,
    PiId INTEGER,
    Temperature REAL,
    Humidity REAL,
    Pressure REAL,
    OrientationPitch REAL,
    OrientationRoll REAL,
    OrientationYaw REAL,
    AccelX REAL,
    AccelY REAL,
    AccelZ REAL,
    MagX REAL,
    MagY REAL,
    MagZ REAL,
    CompassHeading REAL,
    GyroPitch REAL,
    GyroRoll REAL,
    GyroYaw REAL,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PiId) REFERENCES Pi(PiId)
);
"@
Invoke-SQLiteQuery -Connection $conn -Query $createSenseHatTable
# Function to add a new Pi
<#
.SYNOPSIS
    Adds a new Pi record to the Pi table.
.PARAMETER Hostname
    The hostname of the Pi.
.PARAMETER Location
    The location of the Pi.
#>
function Add-Pi {
    param(
        [string]$Hostname,
        [string]$Location
    )
    $query = "INSERT INTO Pi (Hostname, Location) VALUES (@Hostname, @Location);"
    $params = @{ Hostname = $Hostname; Location = $Location }
    Invoke-SQLiteQuery -Connection $conn -Query $query -SqlParameters $params
}

# Function to update Pi info
<#
.SYNOPSIS
    Updates an existing Pi record in the Pi table.
.PARAMETER PiId
    The ID of the Pi to update.
.PARAMETER Hostname
    The new hostname.
.PARAMETER Location
    The new location.
#>
function Update-Pi {
    param(
        [int]$PiId,
        [string]$Hostname,
        [string]$Location
    )
    $query = "UPDATE Pi SET Hostname = @Hostname, Location = @Location WHERE PiId = @PiId;"
    $params = @{ PiId = $PiId; Hostname = $Hostname; Location = $Location }
    Invoke-SQLiteQuery -Connection $conn -Query $query -SqlParameters $params
}

# Function to add GPIO data
<#
.SYNOPSIS
    Adds a new GPIO record to the GPIO table.
.PARAMETER PiId
    The ID of the Pi.
.PARAMETER PinNumber
    The GPIO pin number.
.PARAMETER Status
    The status of the pin (e.g., HIGH/LOW).
#>
function Add-GPIO {
    param(
        [int]$PiId,
        [int]$PinNumber,
        [string]$Status
    )
    $query = "INSERT INTO GPIO (PiId, PinNumber, Status) VALUES (@PiId, @PinNumber, @Status);"
    $params = @{ PiId = $PiId; PinNumber = $PinNumber; Status = $Status }
    Invoke-SQLiteQuery -Connection $conn -Query $query -SqlParameters $params
}

<#
.SYNOPSIS
    Adds a new SenseHat record to the SenseHat table.
.PARAMETER PiId
    The ID of the Pi.
.PARAMETER Temperature
    The temperature value.
.PARAMETER Humidity
    The humidity value.
.PARAMETER Pressure
    The pressure value.
.PARAMETER OrientationPitch
    The pitch orientation value.
.PARAMETER OrientationRoll
    The roll orientation value.
.PARAMETER OrientationYaw
    The yaw orientation value.
.PARAMETER AccelX
    The X acceleration value.
.PARAMETER AccelY
    The Y acceleration value.
.PARAMETER AccelZ
    The Z acceleration value.
.PARAMETER MagX
    The X magnetic value.
.PARAMETER MagY
    The Y magnetic value.
.PARAMETER MagZ
    The Z magnetic value.
.PARAMETER CompassHeading
    The compass heading value.
#>
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
        [double]$MagZ,
        [double]$CompassHeading,
        [double]$GyroPitch,
        [double]$GyroRoll,
        [double]$GyroYaw
    )
    $query = @"
INSERT INTO SenseHat (
	PiId, Temperature, Humidity, Pressure, OrientationPitch, OrientationRoll, OrientationYaw,
	AccelX, AccelY, AccelZ, MagX, MagY, MagZ, CompassHeading, GyroPitch, GyroRoll, GyroYaw
) VALUES (
	@PiId, @Temperature, @Humidity, @Pressure, @OrientationPitch, @OrientationRoll, @OrientationYaw,
	@AccelX, @AccelY, @AccelZ, @MagX, @MagY, @MagZ, @CompassHeading, @GyroPitch, @GyroRoll, @GyroYaw
);
"@
    $params = @{ PiId = $PiId; Temperature = $Temperature; Humidity = $Humidity; Pressure = $Pressure;
        OrientationPitch = $OrientationPitch; OrientationRoll = $OrientationRoll; OrientationYaw = $OrientationYaw;
        AccelX = $AccelX; AccelY = $AccelY; AccelZ = $AccelZ; MagX = $MagX; MagY = $MagY; MagZ = $MagZ; CompassHeading = $CompassHeading;
        GyroPitch = $GyroPitch; GyroRoll = $GyroRoll; GyroYaw = $GyroYaw 
    }
    Invoke-SQLiteQuery -Connection $conn -Query $query -SqlParameters $params
}

<#
.SYNOPSIS
    Clears all tables and resets ID counters in the database.
#>
function Clear-Database {
    Write-Host "Clearing all tables and resetting ID counters in the database..."
    Invoke-SQLiteQuery -Connection $conn -Query "DELETE FROM GPIO;"
    Invoke-SQLiteQuery -Connection $conn -Query "DELETE FROM SenseHat;"
    Invoke-SQLiteQuery -Connection $conn -Query "DELETE FROM Pi;"
    # Reset AUTOINCREMENT counters
    Invoke-SQLiteQuery -Connection $conn -Query "DELETE FROM sqlite_sequence WHERE name IN ('Pi', 'GPIO', 'SenseHat');"
    Write-Host "Database cleared and ID counters reset."
}

# Function to run a test scenario
<#
.SYNOPSIS
    Runs a test scenario to demonstrate database operations.
#>
function Test-DatabaseScenario {
    Write-Host "--- Test Scenario: Database Operations ---"
    # Add a new Pi
    Add-Pi -Hostname "raspberrypi-01" -Location "Lab"
    # Get PiId of the last inserted Pi
    $lastPiId = (Invoke-SQLiteQuery -Connection $conn -Query "SELECT PiId FROM Pi ORDER BY PiId DESC LIMIT 1;").PiId
    Write-Host "Inserted PiId: $lastPiId"

    # Add GPIO data
    Add-GPIO -PiId $lastPiId -PinNumber 17 -Status "HIGH"
    Add-GPIO -PiId $lastPiId -PinNumber 18 -Status "LOW"

    # Add SenseHat data
    Add-SenseHat -PiId $lastPiId -Temperature 22.5 -Humidity 45.2 -Pressure 1013.1 -OrientationPitch 1.2 -OrientationRoll 0.8 -OrientationYaw 0.5 -AccelX 0.01 -AccelY 0.02 -AccelZ 0.03 -MagX 0.1 -MagY 0.2 -MagZ 0.3

    # Update Pi info
    Update-Pi -PiId $lastPiId -Hostname "raspberrypi-01-updated" -Location "Office"

    # Print all Pi records
    Write-Host "Pi Table:"
    Invoke-SQLiteQuery -Connection $conn -Query "SELECT * FROM Pi;" | Format-Table
    # Print all GPIO records
    Write-Host "GPIO Table:"
    Invoke-SQLiteQuery -Connection $conn -Query "SELECT * FROM GPIO;" | Format-Table
    # Print all SenseHat records
    Write-Host "SenseHat Table:"
    Invoke-SQLiteQuery -Connection $conn -Query "SELECT * FROM SenseHat;" | Format-Table
}