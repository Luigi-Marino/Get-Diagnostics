function Get-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    
    return [ordered]@{
        Hostname    = $env.COMPUTERNAME
        User        = $cs.UserName
        OS          = $os.Caption
        Version     = $os.Version
        Model       = $cs.Model
        LastBoot    = $os.LastBootUpTime
    }
}

Export-ModuleMember -Function Get-SystemInfo