#Requires -Version 5.1

param(
  [Parameter()]
  [string]
  $version
)

. $PSScriptRoot/utils/index.ps1

$target = "java"
$libs = "$target/libs"
$version = get-version -version $version
$jarVersion = get-jar-version -version $version

if (Test-Path $libs) {
  Remove-Item $libs -Recurse -Force
}
New-Item $libs -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

get-jar -name 'de.ovgu.featureide.fm' -version $jarVersion
copy-jar -name 'de.ovgu.featureide.fm' -version $jarVersion -target $libs


try {
  Push-Location $target
  ./gradlew build
  ThrowOnNativeFailure
}
finally {
  Pop-Location
}
