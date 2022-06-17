#Requires -Version 5.1

$ErrorActionPreference = 'Stop';

# renovate: datasource=github-releases depName=IKVM packageName=ikvm-revived/ikvm
$IKVM_VERSION="8.2.0-prerelease.392"


function install-ikvm {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("net461", "netcoreapp3.1")]
    [string] $tfm,
    [Parameter(Mandatory)]
    [ValidateSet("any", "win7-x64")]
    [string] $platform
  )
  $url = "https://github.com/ikvm-revived/ikvm/releases/download/${IKVM_VERSION}/IKVM-${IKVM_VERSION}-tools-${tfm}-${platform}.zip"
  $file = "$env:TEMP/ikvm-${IKVM_VERSION}-${tfm}-${platform}.zip"
  $target = "./tools/ikvm/${tfm}"

  if (Test-Path $target){
    Remove-Item $target -Recurse -Force
  }

  New-Item $target -ItemType Directory -Force | Out-Null

  if (!(Test-Path $file)){
    Invoke-WebRequest $url -OutFile $file
  }

  Expand-Archive -Path $file -DestinationPath $target

  . $target/ikvm -version
}

install-ikvm -tfm "net461" -platform "any"
install-ikvm -tfm "netcoreapp3.1" -platform "win7-x64"
