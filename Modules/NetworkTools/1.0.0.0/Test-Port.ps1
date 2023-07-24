#requires -Version 3.0 
function Test-Port
{
    <#
            .SYNOPSIS
            Short Description
            .DESCRIPTION
            Detailed Description
            .EXAMPLE
            Test-Port
            explains how to use the command
            can be multiple lines
            .EXAMPLE
            Test-Port
            another example
            can have as many examples as you like
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.String]
        [Alias('Server','Kiste','PC')]
        $ComputerName = 'microsoft.com',
        
        [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.Int32]
        [Alias('Channel','Hafen')]
        $Port = 80,
        
        [Parameter(Mandatory=$false)]
        [System.Int32]
        $TimeoutMilliSec = 1000
    )
    
    process
    {
        try
        {
            $client = [System.Net.Sockets.TcpClient]::new()
            $task = $client.ConnectAsync($ComputerName, $Port)
        
            if ($task.Wait($TimeoutMilliSec))
            {
                $success = $client.Connected
            }
            else
            {
                $success = $false
            }
        }
        catch
        {
            $success = $false
        }
        finally
        {
            $ip = $client.Client.RemoteEndPoint.Address.IPAddressToString
            $client.Close()
            $client.Dispose()
        }
    
        [PSCustomObject]@{
            HostName = $ComputerName
            IP = $ip
            Port = $Port
            Response = $success
        }
    }
}
