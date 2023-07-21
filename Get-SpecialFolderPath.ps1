function Get-SpecialFolderPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [Environment+SpecialFolder]
        $FolderId
        
    )
    
    process
    {
        try
        {
            [System.Environment]::GetFolderPath($FolderId)
        }
        catch
        {
            Write-Warning "Error occured höhöhö: $_"
        }
    }
}