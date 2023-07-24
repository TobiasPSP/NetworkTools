function Get-Ipv4Segment
{
    <#
        .SYNOPSIS
        Short Description
        .DESCRIPTION
        Detailed Description
        .EXAMPLE
        Get-Ipv4Segment
        explains how to use the command
        can be multiple lines
        .EXAMPLE
        Get-Ipv4Segment
        another example
        can have as many examples as you like
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0, HelpMessage='Please add a help message here')]
        [Object]
        $From,
        
        [Parameter(Mandatory=$true, Position=1, HelpMessage='Please add a help message here')]
        [Object]
        $To
    )
    
    
    
    
    
    $ipFromBytes =($From -as [IPAddress]).GetAddressBytes()
    $ipToBytes = ($To -as [IPAddress]).GetAddressBytes()
    
    # change endianness (reverse bytes)
    [array]::Reverse($ipFromBytes)
    [array]::Reverse($ipToBytes)
    
    # convert reversed bytes to uint32
    $start=[BitConverter]::ToUInt32($ipFromBytes, 0)
    $end=[BitConverter]::ToUInt32($ipToBytes, 0)
    
    # enumerate from start to end uint32
    for($x = $start; $x -le $end; $x++)
    {
        # split uit32 back into bytes
        $ip=[bitconverter]::getbytes($x)
        # reverse bytes back to normal
        [Array]::Reverse($ip)
        # output ipv4 address as string
        $ip -join '.'
    }
}