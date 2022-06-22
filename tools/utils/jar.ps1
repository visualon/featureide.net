#Requires -Version 5.1

# TODO: patch jar https://stackoverflow.com/questions/20269202/remove-files-from-zip-file-with-powershell

function get-jar {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("de.ovgu.featureide.fm", "org.sat4j.core", "org.sat4j.pb")]
    [string] $name,

    [Parameter(Mandatory)]
    [string] $version
  )
  $file = "$tmp/${name}-${version}.jar"
  if (!(Test-Path $file)) {
    if ($name -eq "de.ovgu.featureide.fm") {
      $uri = "https://github.com/FeatureIDE/FeatureIDE/releases/download/v$version/de.ovgu.featureide.lib.fm-v$version.jar"
    }
    else {
      # too big, so use official sat4j libs
      # $uri = "https://raw.githubusercontent.com/FeatureIDE/FeatureIDE/v$version/plugins/de.ovgu.featureide.fm.core/lib/$name.jar"
      $n = $name -replace "org.sat4j.", ""
      $baseUri = "https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/sat4j"
      $uri = "$baseUri/org.ow2.sat4j.$n/$version/org.ow2.sat4j.$n-$version.jar"
    }

    "Download jar $name@$version"
    Invoke-WebRequest -URI $uri -OutFile $file
  }
}

function copy-jar {
  param (
    [Parameter(Mandatory)]
    [ValidateSet("de.ovgu.featureide.fm", "org.sat4j.core", "org.sat4j.pb")]
    [string] $name,

    [Parameter(Mandatory)]
    [string] $target,

    [Parameter(Mandatory)]
    [string] $version
  )

  "Copy jar $name@$version"
  Copy-Item $tmp/$name-${version}.jar -Destination "$target/$name.jar"
}
