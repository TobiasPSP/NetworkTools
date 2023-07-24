
# this script is used to create module releases. It is not meant to be distributed to the releases
# which is why it is excluded in the release process

# whenever you are ready to publish a new release, execute this script and submit the version number
# of the to-be-created release. Version number must be four digit.

param
(
    [Parameter(Mandatory)]
    # make sure version is four numbers:
    [ValidatePattern('(\d{1,5}\.){3}(\d{1,5})')]
    [version]
    $Version
)



# this script is located inside the root folder of the module to be publsihed:
$path　= $PSScriptRoot
# module name equals the root folder name:
$modulname = Split-Path -Path $path -Leaf
# release is to be copied to the subfolder "Modules"
$publishLocation = Join-Path -Path $path -ChildPath Modules
$releaseLocation = Join-Path -Path $path -ChildPath Releases

# module is located in its own child folder:
$modulePathRoot = Join-Path -Path $publishLocation -ChildPath $modulname
# version is a subfolder of this:
$modulePath = Join-Path -Path $modulePathRoot -ChildPath $version
# location for private scripts (visible only inside the module)
$privateScriptPath = Join-Path -Path $modulePath -ChildPath Private 

# create subfolder for module:
$null = New-Item -Path $privateScriptPath -ItemType Directory -Force

# get public scripts but exclude THIS script
$publicScripts = Get-Childitem -Path $Path -File -Filter *.ps1 | Where-Object { $_.FullName -ne $PSCommandPath }
# get private scripts but exclude the subfolder "Modules" with the releases:
$privateScripts = Get-Childitem -Path $Path -Directory -Exclude Modules, Releases | Get-Childitem -File -Filter *.ps1 -Recurse
# get public script names in the module root
$listOfPublicScriptNames = $publicScripts | ForEach-Object { [system.io.path]::GetFileNameWithoutExtension($_.Name) }

# create module manifest file:
New-ModuleManifest -Path "$modulePath\$modulname.psd1" -CompanyName bwi -ModuleVersion $version -RootModule loader.psm1 -Description 'bla' -Copyright '2023 bwi' -FunctionsToExport $listOfPublicScriptNames

# copy public scripts into the module root folder:
$publicScripts | Copy-Item  -Destination $modulePath -Force
# copy private scripts into the private script module path
$privateScripts | Copy-Item  -Destination $privateScriptPath -Force
# create loader.psm1 file that loads public scripts:
$publicScripts | ForEach-Object {
    ". `$PSScriptRoot\" + $_.Name
} |Out-File -FilePath "$modulePath\loader.psm1"
# add paths to all private scripts
$privateScripts | ForEach-Object {
    ". `$PSScriptRoot\Private\" + $_.Name
} | Out-File -FilePath "$modulePath\loader.psm1" -Append

# distribute Module as ZIP


Write-Warning "Module version $version is deployed to $modulePathRoot."
$cmd = "Import-Module -Name '$modulePathRoot' -Verbose"
Set-Clipboard -Value $cmd
Write-Warning "Test-Drive: $cmd (this command has been copied to the clipboard)"

# done, open explorer:
explorer $modulePath



# once the module is released, you can upload it to the powershell gallery or private repositories using Publish-Module
# or you can distribute it yourself using software deployment solutions that you have in place