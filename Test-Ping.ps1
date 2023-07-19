function Test-Ping
{
    <#
            .SYNOPSIS
            Sends ICMP request and waits for a maximum of -TimeoutMillisec milliseconds for an answer
            .EXAMPLE
            Test-Ping -ComputerName microsoft.com
            pings microsoft.com
            .EXAMPLE
            '127.0.0.1','google.de','99.99.99.99' | Test-Ping -TimeoutMillisec 2000
            pings three uris and waits a maximum of 3 seconds for an answer
            .LINK
            https://github.com/TobiasPSP/NetworkTools/blob/main/Test-Ping.ps1
    #>
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]
        $ComputerName,
        
        [int]
        $TimeoutMillisec = 1000
    )
    
    
    
    begin
    {
        $obj = [System.Net.NetworkInformation.Ping]::new()
    }
    
    process
    {
        try
        {
            $obj.Send($ComputerName, $TimeoutMillisec) |
            Select-Object -Property @{N='HostName';E={$ComputerName}},@{N='IP';E={$_.Address}}, @{N='Port';E={'ICMP'}}, @{N='Response';E={$_.Status -eq 'Success'}}
        }
       
        catch [System.Net.NetworkInformation.PingException]
        {
            Write-Warning "$Computername ist kein gültiger Computername"
        }
    }

    end
    {    
        $obj.Dispose()
    }
}

