
function Compact-Path
{
  param
  (
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string[]]
    $Path,
    
    [int]
    $Length = 32
  )
  
  begin
  {
    $Shlwapi = Add-Type -MemberDefinition '
      [DllImport("Shlwapi.dll", CharSet=CharSet.Auto)]public static extern bool PathCompactPathEx([Out] System.Text.StringBuilder pszOut, string szPath, int cchMax, int dwFlags);
    ' -Name 'ShlwapiFunctions' -namespace ShlwapiFunctions -PassThru
  }
  

  process
  {
    $Path | & { process { 
        $StringBuilder = [System.Text.StringBuilder]::new($Length) 
        $Null = $Shlwapi::PathCompactPathEx($StringBuilder, $_, $Length, 0)
        $StringBuilder.ToString()
    }}
  }
}
