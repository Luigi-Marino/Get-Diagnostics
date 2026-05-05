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
        #SecureBoot      = (Confirm-SecureBootUEFI -ErrorAction SilentlyContinue)
        TPM             = (Get-CimInstance -Namespace root\cimv2\security\microsofttpm -Class Win32_Tpm -ErrorAction SilentlyContinue).SpecVersion
        AzureADJoined   = ($dsreg -match "AzureAdJoined\s*:\s*YES")
        WorkplaceJoined = ($dsreg -match "WorkplaceJoined\s*:\s*YES")
        TenantId        = ($dsreg | Select-String "TenantId").ToString().Split(":")[1].Trim()
        DeviceId        = ($dsreg | Select-String "DeviceId").ToString().Split(":")[1].Trim()
        MDMEnrolled     = [bool]$mdm
        MDMProvider     = $mdm.GetValue("ProviderID")
        MDMUPN          = $mdm.GetValue("UPN")
    }
}

Export-ModuleMember -Function Get-Enrollment