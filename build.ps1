param(

    [string] $ikvmc = "c:\tools\ikvm-8.1.5717.0\bin\ikvmc.exe",
    [string] $version = "3.5.2",
    [string] $assemblyversion = "3.0.0",
    [string] $pre = $null
)

Write-Output "Packing files" | Out-Host

if($pre) {
    $version += "-" + $pre
}

nuget pack featureide.csproj -build -version $version -OutputDirectory bin -properties "IKVMC=$ikvmc;Version=$version;AssemblyVersion=$assemblyversion"
