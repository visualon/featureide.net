#Requires -Version 5.1


. $PSScriptRoot/utils/index.ps1


function install-ikvm {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("net461", "netcoreapp3.1")]
    [string] $tfm,
    [Parameter(Mandatory)]
    [ValidateSet("any", "win7-x64")]
    [string] $platform
  )
  $url = "https://github.com/ikvm-revived/ikvm/releases/download/${IKVM_VERSION}/IKVM-${IKVM_VERSION}-tools-ikvmc-${tfm}.zip"
  $file = "$tmp/ikvmc-${IKVM_VERSION}-${tfm}.zip"
  $target = "./tools/ikvm/${tfm}"

  if (Test-Path $target) {
    Remove-Item $target -Recurse -Force
  }

  New-Item $target -ItemType Directory -Force | Out-Null

  if (!(Test-Path $file)) {
    Invoke-WebRequest $url -OutFile $file
    Expand-Archive -Path $file -DestinationPath "$tmp/ikvmc-${IKVM_VERSION}-${tfm}"
  }

  Copy-Item -Path "$tmp/ikvmc-${IKVM_VERSION}-${tfm}/${platform}/*" -Destination $target -Recurse

  (Get-Item "$target/ikvmc.exe").VersionInfo.ProductVersion
  #. $target/ikvmc -version
}

install-ikvm -tfm "net461" -platform "any"
install-ikvm -tfm "netcoreapp3.1" -platform "win7-x64"


dotnet restore
