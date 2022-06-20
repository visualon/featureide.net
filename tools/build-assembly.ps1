#Requires -Version 5.1

param(
  [Parameter()]
  [ValidateSet("net461", "netcoreapp3.1")]
  [string]
  $tfm = '',
  [Parameter()]
  [string]
  $version,

  $sat4jcore,
  $sat4jpb,
  $outdir,
  $configuration
)

# renovate: datasource=github-releases depName=featureide packageName=FeatureIDE/FeatureIDE
$FEATUREIDE_VERSION = "3.3.0"

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $outdir $configuration

if ($env:GITHUB_REF_TYPE -eq 'tag' ) {
  $version = $env:GITHUB_REF_NAME
}

if (!$version) {
  $version = $FEATUREIDE_VERSION
}

# trim leading v
$version = $version -replace "^v?", ""

$major, $minor, $patch = $version.Split('-')[0].Split('.')
$assemblyversion = "$major.0.0.0"

if ($patch.Length -ge 3) {
  $patch = $patch.Substring(0, $patch.Length - 2)
}

$jarVersion = "$major.$minor.$patch"

# if (Test-Path $target) {
#   Remove-Item $target -Recurse -Force
# }
New-Item $target -ItemType Directory -Force | Out-Null

function ThrowOnNativeFailure {
  if (-not $?) {
    throw 'Native Failure'
  }
}


New-Item bin -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

$baseUri = "https://github.com/FeatureIDE/FeatureIDE/releases/download"

function get-jar {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("de.ovgu.featureide.fm")]
    [string] $name
  )
  $file = "$env:TEMP/${name}-${jarVersion}.jar"
  if (!(Test-Path $file)) {
    $uri = "$baseUri/v$jarVersion/$name-v$jarVersion.jar"
    if ($name -eq "de.ovgu.featureide.fm") {
      $uri = $uri -replace "de.ovgu.featureide.fm", "de.ovgu.featureide.lib.fm"
    }
    Invoke-WebRequest -URI $uri -OutFile $file
  }
}

function copy-jar {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("de.ovgu.featureide.fm")]
    [string] $name
  )
  Copy-Item $env:TEMP/$name-${jarVersion}.jar -Destination "$tgt/$name.jar" -Force
}

function build-assembly {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("net461", "netcoreapp3.1")]
    [string] $tfm
  )

  $tgt = New-Item $target/$tfm -ItemType Directory -Force
  copy-jar -name de.ovgu.featureide.fm
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

  $ikvm_args += "-r:$sat4jcore"
  $ikvm_args += "-r:$sat4jpb"


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
get-jar -name de.ovgu.featureide.fm

Write-Output "Compiling jars for version $version" | Out-Host

build-assembly -tfm $tfm
