#Requires -Version 5.1


. $PSScriptRoot/utils/index.ps1

nuget install IKVM -OutputDirectory tools -Version $IKVM_VERSION  -DependencyVersion Ignore -PackageSaveMode 'nuspec'

dotnet restore
