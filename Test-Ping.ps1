function Test-Ping
{
    <#
            .SYNOPSIS
            Short Description
            .DESCRIPTION
            Detailed Description
            .EXAMPLE
            Test-Ping
            explains how to use the command
            can be multiple lines
            .EXAMPLE
            Test-Ping
            another example
            can have as many examples as you like
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
        # NOTE: When you use a SPECIFIC catch block, exceptions thrown by -ErrorAction Stop MAY LACK
        # some InvocationInfo details such as ScriptLineNumber.
        # REMEDY: If that affects you, remove the SPECIFIC exception type [System.Net.NetworkInformation.PingException] in the code below
        # and use ONE generic catch block instead. Such a catch block then handles ALL error types, so you would need to
        # add the logic to handle different error types differently by yourself.
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

