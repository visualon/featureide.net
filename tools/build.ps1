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

$target = "bin"

$version = get-version -version $version
$jarVersion = get-jar-version -version $version
$assemblyversion = get-assembly-version -version $version

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

Write-Output "Compiling jars for version $version" | Out-Host

build-assembly -target $target -tfm net461 -platform win7-x64 -assemblyversion $assemblyversion -IkvmDebug $IkvmDebug
build-assembly -target $target -tfm netcoreapp3.1 -platform win7-x64 -assemblyversion $assemblyversion -IkvmDebug $IkvmDebug

Write-Output "Packing files" | Out-Host


nuget pack featureide.nuspec -OutputDirectory bin -version $version
ThrowOnNativeFailure
