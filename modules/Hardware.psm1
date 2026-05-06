function Get-HardwareSummary {
    $cpu = Get-CimInstance Win32_Processor
    $cs = Get-CimInstance Win32_ComputerSystem
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

    $drives = $disk | ForEach-Object {
        [ordered]@{
            Drive = $_.DeviceID
            FreeGB = [math]::Round($_.FreeSpace/1GB, 2)
            TotalGB = [math]::Round($_.Size/1GB, 2)
        }
    }

    return [ordered]@{
        CPU             = $cpu.Name
        Cores           = $cpu.NumberOfCores
        LogicalProcessors = $cpu.NumberOfLogicalProcessors
        RAM_GB          = [math]::Round($cs.TotalPhysicalMemory/1GB, 2)
        Drives          = $drives
    }
}

Export-ModuleMember -Function Get-HardwareSummary