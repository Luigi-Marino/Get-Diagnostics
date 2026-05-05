function Get-DsRegValue {
    param(
        [string]$Output,
        [string]$Key
    )

    $line = $Output | Select-String -Pattern "^\s*$Key\s*:\s*(.+)$"
    if ($line) {
        return $line.Matches.Groups[1].Value.Trim()
    }
    return $null
}

function Get-Enrollment {
    $cs = Get-CimInstance Win32_ComputerSystem
    $dsreg = dsregcmd /status | Out-String
    $mdmKey = "HKLM:\SOFTWARE\Microsoft\Enrollments"
    $mdm = Get-ChildItem $mdmKey -ErrorAction SilentlyContinue |
        Where-Object { $_.GetValue("ProviderID") } |
        Select-Object -First 1
    
    return [ordered]@{
        Domain          = $cs.Domain
        IsDomainJoined  = $cs.PartOfDomain
        AzureADJoined   = Get-DsRegValue -Output $dsreg -Key "AzureAdJoined"
        EntJoined       = Get-DsRegValue -Output $dsreg -Key "EnterpriseJoined"
        TenantName      = Get-DsRegValue -Output $dsreg -Key "TenantName"
        TPM             = Get-DsRegValue -Output $dsreg -Key "TpmProtected"
        MDMEnrolled     = [bool]$mdm
        MDMProvider     = $mdm.GetValue("ProviderID")
    }
}

Export-ModuleMember -Function Get-Enrollment