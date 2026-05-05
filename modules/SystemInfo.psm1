function Get-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    
    return [ordered]@{
        Hostname        = $env:COMPUTERNAME
        User            = $cs.UserName
        OS              = $os.Caption
        Version         = $os.Version
        Manufacturer    = $cs.Manufacturer
        Model           = $cs.Model
        SerialNumber    = (Get-CimInstance Win32_BIOS).SerialNumber
        LastBoot        = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
        InstallDate     = [Management.ManagementDateTimeConverter]::ToDateTime($os.InstallDate)

    }
}

Export-ModuleMember -Function Get-SystemInfo