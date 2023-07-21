function Test-Online {
[CmdletBinding()]

    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String[]]
    $ComputerName,
    [Int32]
    $Port = 0,
    [switch]
    $CheckDNS,
    [switch]
    $ExcludeOnline,
    [switch]
    $IncludeOffline,
    [switch]
    $ExcludeDNSFailures,
    [Int32]
    $TimeOut = 2000,
    [Int32]
    $ThrottleLimit = 10
    )
begin {

        $c = 0
        $s = Get-Date
        $ScriptBlock = {
            param($ComputerName, $Port = 80, [Bool]$CheckDNS, [Bool]$ExcludeOnline, [Bool]$IncludeOffline,[Int32]$timeout = 500, [Bool]$ExcludeDNSFailures)
            $online = $false
            $status = 'offline'
            try { 
                if ($Port -lt 1) {
                    $obj = New-Object system.Net.NetworkInformation.Ping
                    $rv = $obj.Send($computername, $timeout)
                    if ($rv.status -eq 'Success') { 
                        $online = $true
                        $status = 'online'
                    }
                } else {
                    $tcpobject = new-Object system.Net.Sockets.TcpClient 
                    $connect = $tcpobject.BeginConnect($computername,$port,$null,$null) 
                    $wait = $connect.AsyncWaitHandle.WaitOne($timeout,$false) 
                    if(!$wait) { 
                        $tcpobject.Close() 
                        $online = $false
                    } else { 
                        try { 
                            [void]$tcpobject.EndConnect($connect)
                            $online = $true
                            $status = 'online'
                        }
                        catch { 
                            $online = $false
                        } 
                        $tcpobject.Close() 
                    } 
                    $tcpobject = $null
                }
                if ( ($online -and (-not $ExcludeOnline)) -or ((-not $online) -and $IncludeOffline) ) {
                    if ($CheckDNS) { 
                        if ($computername -like '*.*.*.*') {
                            try { $result = [System.Net.Dns]::GetHostByAddress($computername) | 
                                Select-Object HostName, Status, Aliases, AddressList
                                $result.Status = $status
                                $result
                            } catch {
                                if ($ExcludeDNSFailures -eq $false) {
                                    $result = New-Object PSObject |
                                    Select-Object HostName, Status, Aliases, AddressList
                                    $result.Status = $status
                                    $result.HostName = $Computername
                                    $result
                                }
                            }
                        } else {
                            try { $result = [System.Net.Dns]::GetHostByName($computername) | 
                                Select-Object HostName, Status, Aliases, AddressList
                                $result.Status = $status
                                $result
                            } catch {
                                if ($ExcludeDNSFailures -eq $false) {
                                    $result = New-Object PSObject |
                                    Select-Object HostName, Status, Aliases, AddressList
                                    $result.Status = $status
                                    $result.HostName = $Computername
                                    $result
                                }
                            }
                        }
                    } else {
                        $computername
                    } 
                }
            } catch {  }
        }
        $iss = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $rp = [runspacefactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.Open()
        $jobs = New-Object System.Collections.ArrayList
        function Get-Results {
            param([switch]$wait)
            do {
                $hasdata = $false
                foreach($job in $jobs) {
                    if ($job.job -ne $null -and $job.job.isCompleted) {
                        $job.powershell.EndInvoke($job.job)
                        $job.powershell.dispose()
                        $job.job = $null
                        $job.powershell = $null
                    } elseif ($job.job -ne $null) {
                        $hasdata = $true
                    }
                } 
                if ($hasdata -and $wait) {Start-Sleep -Milliseconds 100}
            } while ($hasdata -and $wait)
        }
    
}
process {

        $ComputerName | ForEach-Object {
      $c++
            $p = [powershell]::Create().AddScript($ScriptBlock).AddArgument($_).AddArgument($Port).AddArgument($CheckDNS).AddArgument($ExcludeOnline).AddArgument($IncludeOffline).AddArgument($timeout).AddArgument($ExcludeDNSFailures)
            $p.RunspacePool = $rp
            $rv = 1 | Select-Object Job, PowerShell
            $rv.PowerShell = $p
            $rv.Job = $p.BeginInvoke()
            [void]$jobs.Add($rv) 
            Get-Results
        }
    
}
end {

        Get-Results -wait
        $t = ((Get-Date) - $s).TotalSeconds
        Write-Verbose ("Checked online and DNS status for $c computers in {0:0.0} seconds ({1:0.000} sec/computer)" -f $t, ($t / $c))
        $rp.Close()
    
}

}