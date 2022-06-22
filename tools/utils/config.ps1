#Requires -Version 5.1

# renovate: datasource=github-releases depName=featureide packageName=FeatureIDE/FeatureIDE
$FEATUREIDE_VERSION = "3.8.3"

# newer version is broken
#disabled renovate: datasource=maven depName=sat4j packageName=org.ow2.sat4j:org.ow2.sat4j.pom
$SAT4J_VERSION = "2.3.5"

# used to silence warnings
Set-Variable -Name FEATUREIDE_VERSION -Value $FEATUREIDE_VERSION
Set-Variable -Name SAT4J_VERSION -Value $SAT4J_VERSION
