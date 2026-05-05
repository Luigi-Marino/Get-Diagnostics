# ============================================================
# Get-Diagnostics
# ============================================================

# Add Types
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------
$Repo = "Get-Diagnostics"
$RepoBase = "https://raw.githubusercontent.com/Luigi-Marino/$Repo/main"
$ModuleNames = @(
    "template_module.psm1",
    "SystemInfo.psm1"
)
$TimeStamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
#$OutputPath = "$env:USERPROFILE\Desktop\DiagnosticsReport_$TimeStamp.json"
$OutputPath = "C:\Test\DiagnosticsReport_$TimeStamp.json"


# ------------------------------------------------------------
# MODULE LOADER
# ------------------------------------------------------------
function Load-RemoteModules {
    param($BaseURL, $Modules)

    foreach ($m in $Modules) {
        Write-Host "$BaseURL/modules/$m"
        $url = "$BaseURL/modules/$m"
        $code = Invoke-RestMethod $url

        $mod = New-Module -ScriptBlock ([ScriptBlock]::Create($code)) -Name $m
        Import-Module $mod -Force
    }
}

# ------------------------------------------------------------
# DETECT EXECUTION METHOD
# ------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Load-RemoteModules -BaseUrl $RepoBase -Modules $ModuleNames
}
else {
    Get-ChildItem "$PSScriptRoot/modules" -Filter *.psm1 |
        ForEach-Object { Import-Module $_.FullName -Force }
}

# ------------------------------------------------------------
# BUILD UI
# ------------------------------------------------------------
# Form Container
$form                   = New-Object System.Windows.Forms.Form
$form.Text              = "Diagnostics Utility"
$form.Size              = New-Object System.Drawing.Size(500,380)
$form.StartPosition     = "CenterScreen"
$form.FormBorderStyle   = "FixedDialog"
$form.MaximizeBox       = $false
$form.Font              = New-Object System.Drawing.Font("Segoe UI", 9)

# Group Box (Left Side)
$group                  = New-Object System.Windows.Forms.GroupBox
$group.Text             = "Select Diagnostic Modules"
$group.Location         = New-Object System.Drawing.Point(20,20)
$group.Size             = New-Object System.Drawing.Size(200,250)
$group.Padding          = New-Object System.Windows.Forms.Padding(10)
$form.Controls.Add($group)

# Flow Layout Panel (Inside Group)
$flow                   = New-Object System.Windows.Forms.FlowLayoutPanel
$flow.Location          = New-Object System.Drawing.Point (10,20)
$flow.Size              = New-Object System.Drawing.Size(180,220)
$flow.FlowDirection     = "TopDown"
$flow.WrapContents      = $false
$flow.AutoScroll        = $false
$flow.Padding           = New-Object System.Windows.Forms.Padding(5)
$group.Controls.Add($flow)

# Checkboxes
$chkSysInfo             = New-Object System.Windows.Forms.CheckBox
$chkHardware            = New-Object System.Windows.Forms.CheckBox
$chkEventLogs           = New-Object System.Windows.Forms.CheckBox
$chkNetwork             = New-Object System.Windows.Forms.CheckBox
$chkProcesses           = New-Object System.Windows.Forms.CheckBox

$chkSysInfo.Text        = "System Info"
$chkHardware.Text       = "Hardware Summary"
$chkEventLogs.Text      = "Event Logs"
$chkNetwork.Text        = "Network Status"
$chkProcesses.Text      = "Top Processes"

foreach ($chk in @($chkSysInfo,$chkHardware,$chkEventLogs,$chkNetwork,$chkProcesses)) {
    $chk.AutoSize = $true
    $chk.MaximumSize = New-Object System.Drawing.Size(180,0)
}

$flow.Controls.AddRange(@(
    $chkSysInfo, $chkHardware, $chkEventLogs,
    $chkNetwork, $chkProcesses
))

# Output Box (Right Side)
$output                 = New-Object System.Windows.Forms.TextBox
$output.Multiline       = $true
$output.ScrollBars      = "None"
$output.Location        = New-Object System.Drawing.Point(240,20)
$output.Size            = New-Object System.Drawing.Size(230,250)
$output.ReadOnly        = $true
$output.BorderStyle     = 'FixedSingle'
$form.Controls.Add($output)

# Run Button
$btnRun                 = New-Object System.Windows.Forms.Button
$btnRun.Text            = "Run Diagnostics"
$btnRun.Location        = New-Object System.Drawing.Point(20,290)
$btnRun.Width           = 450
$btnRun.FlatStyle       = "Flat"
$form.Controls.Add($btnRun)

# ------------------------------------------------------------
# RUN DIAGNOSTICS
# ------------------------------------------------------------

$btnRun.Add_Click({

    $output.Clear()
    $output.AppendText("Running selected diagnostics. `r`n")

    $results = @{}

    # SYSTEM INFO
    if ($chkSysInfo.Checked) {
        $output.AppendText("- Collecting System Info... `r`n")
        $results.SystemInfo = Get-SystemInfo
    }


    # EXPORT RESULTS
    $output.AppendText("Exporting Results...`r`n")
    
    try {
        $Results | ConvertTo-Json -Depth 6 | Out-File -FilePath $OutputPath -Encoding UTF8
        $output.AppendText("`r`n")
        $output.AppendText("Diagnostic Report Saved: $OutputPath`r`n")
    }
    catch {
        $output.AppendText("`r`n")
        $output.AppendText("Failed To Export Results.")
    }
})


# ------------------------------------------------------------
# ENTRY POINT
# ------------------------------------------------------------
#Test-Module
$form.ShowDialog()
