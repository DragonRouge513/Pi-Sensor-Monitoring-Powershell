#region Add Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
#endregion

# Adds a new label to a parent control.
function Add-Label {
    param (
        [System.Windows.Forms.Control]$parentControl,
        [string]$labelText,
        [int]$labelLocationX,
        [int]$labelLocationY,
        [int]$labelWidth = 100,
        [int]$labelHeight = 30
    )
    try {
        if (-not $parentControl) { throw "Parent control cannot be null." }
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelText
        $label.Location = New-Object System.Drawing.Point($labelLocationX, $labelLocationY)
        $label.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
        $label.TextAlign = 'MiddleCenter'
        $label.Font = New-Object System.Drawing.Font('Arial', 14, [System.Drawing.FontStyle]::Bold)
        $label.ForeColor = [System.Drawing.Color]::Red
        $parentControl.Controls.Add($label)
        return $label
    }
    catch {
        Write-Error "Failed to add label: $_"
    }
}

<#
.SYNOPSIS
    Creates and sets up a new Windows Form.
.PARAMETER formText
    The text to display in the form's title bar.
.PARAMETER formWidth
    The width of the form.
.PARAMETER formHeight
    The height of the form.
#>
function Set-Form {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$formText,
        
        [ValidateRange(100, 2000)]
        [int]$formWidth,
        
        [ValidateRange(100, 2000)]
        [int]$formHeight
    )
    try {
        if (-not $formText) {
            throw "Form text cannot be null or empty."
        }
        $form = New-Object System.Windows.Forms.Form
        $form.Text = $formText
        $form.Size = New-Object System.Drawing.Size($formWidth, $formHeight)
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.StartPosition = "CenterScreen"
        $form.AutoScroll = $true
        return $form
    }
    catch {
        Write-Error "Failed to create form: $_"
    }
}

<#
.SYNOPSIS
    Adds a new tab page to a TabControl.
.PARAMETER tabControl
    The TabControl to add the tab page to.
.PARAMETER tabText
    The text to display on the tab page.
#>
function Add-tabPage {
    param (
        [System.Windows.Forms.TabControl]$tabControl,
        [ValidateNotNullOrEmpty()]
        [string]$tabText
    )
    try {
        if (-not $tabControl) {
            throw "TabControl cannot be null."
        }
        if (-not $tabText) {
            throw "Tab text cannot be null or empty."
        }
        $tabPage = New-Object System.Windows.Forms.TabPage
        $tabPage.Text = $tabText
        $tabPage.AutoScroll = $true
        $tabControl.TabPages.Add($tabPage)
        return $tabPage
    }
    catch {
        Write-Error "Failed to add tab page: $_"
    }
}

<#
.SYNOPSIS
    Adds a new TabControl to a parent control.
.PARAMETER parentControl
    The parent control to add the TabControl to.
.PARAMETER tabControlWidth
    The width of the TabControl.
.PARAMETER tabControlHeight
    The height of the TabControl.
.PARAMETER tabControlLocationX
    The X location of the TabControl.
.PARAMETER tabControlLocationY
    The Y location of the TabControl.
#>
function Add-TabControl {
    param (
        [System.Windows.Forms.Control]$parentControl,
        [int]$tabControlWidth,
        [int]$tabControlHeight,
        [int]$tabControlLocationX,
        [int]$tabControlLocationY
    )
    try {
        if (-not $parentControl) {
            throw "Parent control cannot be null."
        }
        $tabControl = New-Object System.Windows.Forms.TabControl
        $tabControl.Size = New-Object System.Drawing.Size($tabControlWidth, $tabControlHeight)
        $tabControl.Location = New-Object System.Drawing.Point($tabControlLocationX, $tabControlLocationY)
        $parentControl.Controls.Add($tabControl)
        return $tabControl
    }
    catch {
        Write-Error "Failed to add tab control: $_"
    }
}

<#
.SYNOPSIS
    Adds a new button to a parent control.
.PARAMETER parentControl
    The parent control to add the button to.
.PARAMETER buttonText
    The text to display on the button.
.PARAMETER buttonLocationX
    The X location of the button.
.PARAMETER buttonLocationY
    The Y location of the button.
.PARAMETER buttonWidth
    The width of the button. Default is 100.
.PARAMETER buttonHeight
    The height of the button. Default is 30.
#>
function Add-Button {
    param (
        [System.Windows.Forms.Control]$parentControl,
        
        [ValidateNotNullOrEmpty()]
        [string]$buttonText,
        
        [int]$buttonLocationX,
        [int]$buttonLocationY,
        
        [int]$buttonWidth = 100,
        [int]$buttonHeight = 30
    )
    try {
        if (-not $parentControl) {
            throw "Parent control cannot be null."
        }
        if (-not $buttonText) {
            throw "Button text cannot be null or empty."
        }
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $buttonText
        $button.Location = New-Object System.Drawing.Point($buttonLocationX, $buttonLocationY)
        $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
        $parentControl.Controls.Add($button)
        return $button
    }
    catch {
        Write-Error "Failed to add button: $_"
    }
}

<#
.SYNOPSIS
    Adds a new DataGridView table to a parent control.
.PARAMETER parentControl
    The parent control to add the table to.
.PARAMETER tableWidth
    The width of the table.
.PARAMETER tableHeight
    The height of the table.
.PARAMETER tableLocationX
    The X location of the table.
.PARAMETER tableLocationY
    The Y location of the table.
#>
function Add-Table {
    param (
        [System.Windows.Forms.Control]$parentControl,
        [int]$tableWidth,
        [int]$tableHeight,
        [int]$tableLocationX,
        [int]$tableLocationY
    )
    try {
        if (-not $parentControl) {
            throw "Parent control cannot be null."
        }
        $table = New-Object System.Windows.Forms.DataGridView
        $table.Size = New-Object System.Drawing.Size($tableWidth, $tableHeight)
        $table.Location = New-Object System.Drawing.Point($tableLocationX, $tableLocationY)
        $parentControl.Controls.Add($table)
        return $table
    }
    catch {
        Write-Error "Failed to add table: $_"
    }
}

<#
.SYNOPSIS
    Sets the data and appearance of a DataGridView table.
.PARAMETER table
    The DataGridView table to set.
.PARAMETER data
    The data to populate the table with.
.PARAMETER highlightPin
    The pin to highlight in the table.
#>
function Set-Table {
    param (
        [System.Windows.Forms.DataGridView]$table,
        [array]$data,
        [string]$highlightPin
    )
    try {
        if (-not $table) {
            throw "Table cannot be null."
        }
        if (-not $data -or $data.Length -eq 0 -or $data[0].Length -le 1) {
            throw "Invalid data format for table. Ensure the data array is not empty and has at least two columns."
        }
        $table.Rows.Clear()
        $table.ColumnCount = $data[0].Length - 1
        for ($i = 1; $i -lt $data.Length; $i++) {
            $row = $table.Rows.Add()
            for ($j = 1; $j -lt $data[$i].Length; $j++) {
                if ($null -ne $table.Rows[$row].Cells[$j - 1]) {
                    $table.Rows[$row].Cells[$j - 1].Value = $data[$i][$j]
                    if ($data[$i][1] -eq $highlightPin) {
                        $table.Rows[$row].DefaultCellStyle.BackColor = [System.Drawing.Color]::Yellow
                    }
                }
            }
        }
        for ($j = 1; $j -lt $data[0].Length; $j++) {
            $table.Columns[$j - 1].HeaderText = $data[0][$j]
        }
        for ($i = 1; $i -lt $data.Length; $i++) {
            $table.Rows[$i - 1].HeaderCell.Value = $data[$i][0]
        }
        $table.RowHeadersWidth = 10
        $table.ColumnHeadersHeight = 20
        $table.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
    }
    catch {
        Write-Error "Failed to set table: $_"
    }
}

<#
.SYNOPSIS
    Tests values and notifies if incorrect values are detected.
.PARAMETER pi
    The Pi identifier.
.PARAMETER pin
    The pin to test.
.PARAMETER startTime
    The start time for the test.
.PARAMETER endTime
    The end time for the test.
#>
function Test-ValuesAndNotify {
    param (
        [int]$pi,
        [ValidateNotNullOrEmpty()]
        [string]$pin,
        [datetime]$startTime,
        [datetime]$endTime
    )
    try {
        if (-not $pi) {
            throw "Pi cannot be null."
        }
        if (-not $pin) {
            throw "Pin cannot be null or empty."
        }
        if (-not $startTime) {
            throw "Start time cannot be null."
        }
        if (-not $endTime) {
            throw "End time cannot be null."
        }
        $dataDB = Get-PiPinSqliteDataLastOfAllPins -pi $pi
        foreach ($data in $dataDB) {
            if ($data.pin -eq $pin -and $data.timestamp -ge $startTime -and $data.timestamp -le $endTime) {
                if ($data.value_data -ne "0") {
                    [System.Windows.Forms.MessageBox]::Show("Incorrect value detected for Pi $pi, Pin $pin at $($data.timestamp)")
                }
            }
        }
    }
    catch {
        Write-Error "Failed to test values and notify: $_"
    }
}

<#
.SYNOPSIS
    Adds a new chart to a parent control.
.PARAMETER parentControl
    The parent control to add the chart to.
.PARAMETER chartWidth
    The width of the chart.
.PARAMETER chartHeight
    The height of the chart.
.PARAMETER chartLocationX
    The X location of the chart.
.PARAMETER chartLocationY
    The Y location of the chart.
#>
function Add-Chart {
    param (
        [System.Windows.Forms.Control]$parentControl,
        [int]$chartWidth,
        [int]$chartHeight,
        [int]$chartLocationX,
        [int]$chartLocationY
    )
    try {
        if (-not $parentControl) {
            throw "Parent control cannot be null."
        }
        $chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
        $chart.Size = New-Object System.Drawing.Size($chartWidth, $chartHeight)
        $chart.Location = New-Object System.Drawing.Point($chartLocationX, $chartLocationY)
        $chartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $chart.ChartAreas.Add($chartArea)
        # Add two series: Temperature and Humidity
        $seriesTemp = New-Object System.Windows.Forms.DataVisualization.Charting.Series
        $seriesTemp.Name = "Temperature"
        $seriesTemp.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
        $chart.Series.Add($seriesTemp)
        $seriesHum = New-Object System.Windows.Forms.DataVisualization.Charting.Series
        $seriesHum.Name = "Humidity"
        $seriesHum.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
        $chart.Series.Add($seriesHum)
        $parentControl.Controls.Add($chart)
        return $chart
    }
    catch {
        Write-Error "Failed to add chart: $_"
    }
}

<#
.SYNOPSIS
    Sets the data and appearance of a chart.
.PARAMETER chart
    The chart to set.
.PARAMETER data
    The data to populate the chart with.
#>
function Set-Chart {
    param (
        [System.Windows.Forms.DataVisualization.Charting.Chart]$chart,
        [hashtable]$data
    )
    try {
        if (-not $chart) { throw "Chart cannot be null." }
        if (-not $data -or $data.Count -eq 0) { throw "Data cannot be null or empty." }
        # Clear all series
        foreach ($series in $chart.Series) {
            $series.Points.Clear()
        }
        foreach ($seriesName in $data.Keys) {
            $seriesData = $data[$seriesName]
            $series = $chart.Series[$seriesName]
            if ($series -and $seriesData) {
                foreach ($point in $seriesData) {
                    if ($point.Length -ge 2) {
                        $series.Points.AddXY($point[0], $point[1])
                    }
                }
            }
        }
    }
    catch {
        Write-Error "Failed to set chart: $_"
    }
}