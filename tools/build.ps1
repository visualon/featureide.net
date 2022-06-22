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

function build-assembly {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("net461", "netcoreapp3.1")]
    [string] $tfm
  )

  $tgt = New-Item $target/$tfm -ItemType Directory -Force
  copy-jar -name 'de.ovgu.featureide.fm' -version $jarVersion -target $tgt
  copy-jar -name 'org.sat4j.core' -version $SAT4J_VERSION -target $tgt
  copy-jar -name 'org.sat4j.pb' -version $SAT4J_VERSION -target $tgt
  Copy-Item tools/ikvm/$tfm/* -Destination $tgt -Recurse

  $ikvm_args = @(
    "-target:library",
    "-classloader:ikvm.runtime.AppDomainAssemblyClassLoader",
    "-keyfile:../../featureide.snk",
    "-version:$assemblyversion",
    "-fileversion:$version"
  )

  if ($IkvmDebug) {
    $ikvm_args += '-debug'
  }

  if ($tfm -eq "netcoreapp3.1") {
    $ikvm_args += "-nostdlib", "-r:./refs/*.dll"
  }

  $ikvm_args += "{", "org.sat4j.core.jar", "}"
  $ikvm_args += "{", "org.sat4j.pb.jar", "}"
  $ikvm_args += "{", "de.ovgu.featureide.fm.jar", "}"

  try {
    Push-Location $tgt
    . ./ikvmc $ikvm_args
    ThrowOnNativeFailure
  }
  finally {
    Pop-Location
  }
}

Write-Output "Downloading jars for version $jarVersion" | Out-Host
get-jar -name 'de.ovgu.featureide.fm' -version $jarVersion
get-jar -name 'org.sat4j.core' -version $SAT4J_VERSION
get-jar -name 'org.sat4j.pb' -version $SAT4J_VERSION

Write-Output "Compiling jars for version $version" | Out-Host

build-assembly -tfm net461
build-assembly -tfm netcoreapp3.1

Write-Output "Packing files" | Out-Host


nuget pack featureide.nuspec -OutputDirectory bin -version $version
ThrowOnNativeFailure
