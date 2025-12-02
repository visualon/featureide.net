#Requires -Version 5.1

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# renovate: datasource=github-releases depName=featureide packageName=FeatureIDE/FeatureIDE
$FEATUREIDE_VERSION = "v3.11.1"

# used to silence warnings
Set-Variable -Name FEATUREIDE_VERSION -Value $FEATUREIDE_VERSION
Set-Variable -Name tmp -Value ([System.IO.Path]::GetTempPath())
