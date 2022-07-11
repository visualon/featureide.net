#Requires -Version 5.1


. $PSScriptRoot/utils/index.ps1

$target = "./tools/ikvm"
if (Test-Path $target) {
  Remove-Item $target -Recurse -Force
}

nuget install IKVM -OutputDirectory tools -Version $IKVM_VERSION  -DependencyVersion Ignore -PackageSaveMode 'nuspec'
Move-Item -Path .\tools\IKVM.$IKVM_VERSION -Destination .\tools\ikvm

# fix missing runtime assemblies
Copy-Item -Path .\tools\ikvm\lib\net461\*.dll -Destination .\tools\ikvm\bin\ikvmc\net461\any\
Copy-Item -Path .\tools\ikvm\lib\netcoreapp3.1\*.dll -Destination .\tools\ikvm\bin\ikvmc\netcoreapp3.1\win7-x64\

dotnet restore
