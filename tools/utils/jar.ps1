#Requires -Version 5.1

# TODO: patch jar https://stackoverflow.com/questions/20269202/remove-files-from-zip-file-with-powershell

function get-jar {
  param (
    [Parameter(Mandatory)]
    [ValidateSet('de.ovgu.featureide.fm')]
    [string] $name,

    [Parameter(Mandatory)]
    [string] $version
  )
  $file = "$tmp/${name}-${version}.jar"
  if ($name -eq 'de.ovgu.featureide.fm') {
    $uri = "https://github.com/FeatureIDE/FeatureIDE/releases/download/v$version/de.ovgu.featureide.lib.fm-v$version.jar"
  }
  else {
    throw "$name is not supported"
  }

  if ((Test-Path $file)) {
    "Skipping download jar $name@$version ($uri)"
  }
  else {
    "Download jar $name@$version ($uri)"
    Invoke-WebRequest -URI $uri -OutFile $file
  }
}

function copy-jar {
  param (
    [Parameter(Mandatory)]
    [ValidateSet('de.ovgu.featureide.fm')]
    [string] $name,

    [Parameter(Mandatory)]
    [string] $target,

    [Parameter(Mandatory)]
    [string] $version
  )

  "Copy jar $name@$version"
  Copy-Item $tmp/$name-${version}.jar -Destination "$target/$name.jar"
}
