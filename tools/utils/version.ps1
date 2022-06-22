#Requires -Version 5.1


function get-version {
  param (
    [Parameter()]
    [string] $version
  )
  if ($env:GITHUB_REF_TYPE -eq 'tag' ) {
    $version = $env:GITHUB_REF_NAME
  }

  if (!$version) {
    $version = $FEATUREIDE_VERSION
  }

  # trim leading v
  $version -replace "^v?", ""
}


function get-jar-version {
  param (
    [Parameter(Mandatory)]
    [string] $version
  )

  $major, $minor, $patch = $version.Split('-')[0].Split('.')

  if ($patch.Length -ge 3) {
    $patch = $patch.Substring(0, $patch.Length - 2)
  }

  "$major.$minor.$patch"
}

function get-assembly-version {
  param (
    [Parameter(Mandatory)]
    [string] $version
  )

  $major, $minor, $patch = $version.Split('-')[0].Split('.')
  "$major.0.0.0"
}
