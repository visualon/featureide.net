#Requires -Version 5.1

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'


# renovate: datasource=github-releases depName=IKVM packageName=ikvmnet/ikvm
$IKVM_VERSION = "8.11.0"

# renovate: datasource=github-releases depName=featureide packageName=FeatureIDE/FeatureIDE
$FEATUREIDE_VERSION = "v3.11.1"

# newer version is broken
#disabled renovate: datasource=maven depName=sat4j packageName=org.ow2.sat4j:org.ow2.sat4j.pom
$SAT4J_VERSION = "2.3.5"


# used to silence warnings
Set-Variable -Name IKVM_VERSION -Value $IKVM_VERSION
Set-Variable -Name FEATUREIDE_VERSION -Value $FEATUREIDE_VERSION
Set-Variable -Name SAT4J_VERSION -Value $SAT4J_VERSION
Set-Variable -Name tmp -Value ([System.IO.Path]::GetTempPath())
