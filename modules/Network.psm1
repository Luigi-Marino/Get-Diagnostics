function Get-NetworkingBasic {

    # Get active adapters
    $adapters = Get-NetAdapter |
        Where-Object { $_.Status -eq "Up" } |
        Select-Object Name, InterfaceDescription, MacAddress, LinkSpeed, Status

    # Get IPv4 addresses
    $ipv4 = Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -notlike "169.*" -and $_.IPAddress -ne "127.0.0.1" } |
        Select-Object InterfaceAlias, IPAddress, PrefixLength

    # Default gateway test
    $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" |
                Sort-Object RouteMetric |
                Select-Object -First 1).NextHop

    $gatewayReachable = $null
    if ($gateway) {
        $gatewayReachable = Test-Connection -Count 1 -Quiet -ErrorAction SilentlyContinue $gateway
    }

    # DNS resolution test
    $dnsTest = $null
    try {
        $dnsTest = [bool](Resolve-DnsName "microsoft.com" -ErrorAction Stop)
    }
    catch {
        $dnsTest = $false
    }

    # Public IP lookup
    $publicIP = $null
    try {
        $publicIP = Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 3
    }
    catch {
        $publicIP = "Unavailable"
    }

    return [ordered]@{
        Adapters          = $adapters
        IPv4Addresses     = $ipv4
        DefaultGateway    = $gateway
        GatewayReachable  = $gatewayReachable
        DnsResolution     = $dnsTest
        PublicIP          = $publicIP
    }
}

Export-ModuleMember -Function Get-NetworkingBasic
