#Requires -Version 5.1

param(
  [Parameter()]
  [string]
  $version,

  [Parameter()]
  [bool]
  $IkvmDebug
)

. $PSScriptRoot/utils/index.ps1

$target = "libs"

$version = get-version -version $version
$jarVersion = get-jar-version -version $version

if ($version.Contains('-')) {
  $IkvmDebug = $true
}

if (Test-Path $target) {
  Remove-Item $target -Recurse -Force
}

New-Item $target -ItemType Directory -Force | Out-Null



Write-Output "Downloading jars for version $jarVersion" | Out-Host
get-jar -name 'de.ovgu.featureide.fm' -version $jarVersion
get-jar -name 'org.sat4j.core' -version $SAT4J_VERSION
get-jar -name 'org.sat4j.pb' -version $SAT4J_VERSION
copy-jar -name 'de.ovgu.featureide.fm' -version $jarVersion -target $libs
copy-jar -name 'org.sat4j.core' -version $SAT4J_VERSION -target $libs
copy-jar -name 'org.sat4j.pb' -version $SAT4J_VERSION -target $libs

Write-Output "Compiling jars for version $version" | Out-Host

dotnet build

Write-Output "Packing files" | Out-Host


nuget pack featureide.nuspec -OutputDirectory bin -version $version
ThrowOnNativeFailure
