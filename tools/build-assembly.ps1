#Requires -Version 5.1

param(
  [Parameter(Mandatory)]
  [ValidateSet("net461", "netcoreapp3.1")]
  [string]
  $tfm,
  [Parameter()]
  [string]
  $version,

  $outdir,
  $configuration
)

. $PSScriptRoot/utils/index.ps1

$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $outdir $configuration

$version = get-version -version $version
$jarVersion = get-jar-version -version $version
$assemblyversion = get-assembly-version -version $version

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
  Copy-Item $PSScriptRoot/ikvm/$tfm/* -Destination $tgt -Recurse  -Force

  $ikvm_args = @(
    "-target:library",
    "-classloader:ikvm.runtime.AppDomainAssemblyClassLoader",
    "-keyfile:$root/featureide.snk",
    "-version:$assemblyversion",
    "-fileversion:$version"
  )

  if ($tfm -eq "netcoreapp3.1") {
    $ikvm_args += "-nostdlib", "-r:./refs/*.dll"
  }

  if ($configuration -eq "debug"){
    $ikvm_args += '-debug'
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

build-assembly -tfm $tfm
