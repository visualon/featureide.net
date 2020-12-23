#Requires -Version 5.1

param(
    [string] $version = "3.5.5",
    [string] $assemblyversion = "3.0.0",
    [string] $pre = $null
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
function ThrowOnNativeFailure {
  if (-not $?) {
    throw 'Native Failure'
  }
}


New-Item bin -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

$baseUri = "https://github.com/FeatureIDE/FeatureIDE/releases/download"

Write-Output "Downloading jars" | Out-Host
Invoke-WebRequest -URI "$baseUri/v$version/de.ovgu.featureide.lib.fm-v$version.jar" -OutFile bin/de.ovgu.featureide.fm.jar

Write-Output "Packing files" | Out-Host

if($pre) {
    $version += "-" + $pre
}

nuget restore
nuget pack featureide.csproj -build -version $version -OutputDirectory bin -properties "Version=$version;AssemblyVersion=$assemblyversion"
