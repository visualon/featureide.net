function build-assembly {
  param (
    [Parameter(Mandatory)]
    [string]
    $target,

    [Parameter(Mandatory)]
    [ValidateSet("net461", "netcoreapp3.1")]
    [string] $tfm,

    [Parameter(Mandatory)]
    [ValidateSet("any", "win7-x64")]
    [string] $platform,

    [Parameter(Mandatory)]
    [string]
    $assemblyversion,

    [Parameter()]
    [bool]
    $IkvmDebug
   )

  $tgt = New-Item $target/$tfm -ItemType Directory -Force
  copy-jar -name 'de.ovgu.featureide.fm' -version $jarVersion -target $tgt
  copy-jar -name 'org.sat4j.core' -version $SAT4J_VERSION -target $tgt
  copy-jar -name 'org.sat4j.pb' -version $SAT4J_VERSION -target $tgt
  $ikvm = Resolve-Path "$PSScriptRoot/../IKVM.${IKVM_VERSION}"
  $ikvmc = "$ikvm/bin/ikvmc/${tfm}/${platform}/ikvmc.exe"

  $ikvm_args = @(
    "-target:library",
    "-classloader:ikvm.runtime.AppDomainAssemblyClassLoader",
    "-keyfile:../../featureide.snk",
    "-version:$assemblyversion",
    "-fileversion:$version",
    "-lib:$ikvm/bin/ikvmc/${tfm}/${platform}/refs",
    "-nojni",
    "-compressresources",
    "-runtime:$ikvm/lib/${tfm}/IKVM.Runtime.dll"
  )

  if ($IkvmDebug) {
    $ikvm_args += '-debug'
  }

  #if ($tfm -eq "netcoreapp3.1") {
   $ikvm_args += "-nostdlib", "-r:$ikvm/bin/ikvmc/${tfm}/${platform}/refs/*.dll"
  #}

  $ikvm_args += "{", "org.sat4j.core.jar", "}"
  $ikvm_args += "{", "org.sat4j.pb.jar", "}"
  $ikvm_args += "{", "de.ovgu.featureide.fm.jar", "}"

  try {
    Push-Location $tgt
    . $ikvmc $ikvm_args
    ThrowOnNativeFailure
  }
  finally {
    Pop-Location
  }
}
