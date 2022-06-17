#Requires -Version 5.1

param(
  [string] $version = "3.3.0"
)

# renovate: datasource=nuget depName=org.sat4j.pb
$SAT4J_VERSION = "2.3.600-beta.1"

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

$target = "bin"

if ($env:GITHUB_REF_TYPE -eq 'tag' ) {
  $version = $env:GITHUB_REF_NAME
}

# trim leading v
$version = $version -replace "^v?", ""

$major, $minor, $patch = $version.Split('-')[0].Split('.')
$assemblyversion = "$major.0.0.0"

if ($patch.Length -ge 3) {
  $patch = $patch.Substring(0, $patch.Length - 2)
}

$jarVersion = "$major.$minor.$patch"

if (Test-Path $target) {
  Remove-Item $target -Recurse -Force
}
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
    if ($jarVersion -eq "3.3.0") {
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
  Copy-Item $env:TEMP/$name-${jarVersion}.jar -Destination "$tgt/$name.jar"
}

function get-sat4j {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("core", "pb")]
    [string] $name
  )
  if (!(Test-Path $target/org.sat4j.$name.$SAT4J_VERSION)) {
    nuget install "org.sat4j.$name" -Version $SAT4J_VERSION -o $target -PackageSaveMode 'nuspec' -DependencyVersion Ignore -ForceEnglishOutput
  }
}

function build-assembly {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("net461", "netcoreapp3.1")]
    [string] $tfm
  )

  $tgt = New-Item $target/$tfm -ItemType Directory -Force
  copy-jar -name de.ovgu.featureide.fm
  Copy-Item tools/ikvm/$tfm/* -Destination $tgt -Recurse

  $ikvm_args = @(
    "-target:library",
    "-classloader:ikvm.runtime.AppDomainAssemblyClassLoader",
    "-keyfile:../../featureide.snk",
    "-version:$assemblyversion",
    "-fileversion:$version"
  )

  if ($tfm -eq "netcoreapp3.1") {
    $ikvm_args += "-nostdlib", "-r:./refs/*.dll"
  }

  $ikvm_args += "-r:../org.sat4j.core.$SAT4J_VERSION/lib/$tfm/org.sat4j.core.dll"
  $ikvm_args += "-r:../org.sat4j.pb.$SAT4J_VERSION/lib/$tfm/org.sat4j.pb.dll"


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

Write-Output "Downloading sat4j for version $SAT4J_VERSION" | Out-Host
get-sat4j -name core
get-sat4j -name pb

Write-Output "Compiling jars for version $version" | Out-Host

build-assembly -tfm net461
build-assembly -tfm netcoreapp3.1

Write-Output "Packing files" | Out-Host


nuget pack featureide.nuspec -OutputDirectory bin -version $version -properties "sat4jversion=$SAT4J_VERSION"
ThrowOnNativeFailure
