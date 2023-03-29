using de.ovgu.featureide.fm.core.configuration;
using de.ovgu.featureide.fm.core.job;

namespace VisualOn.FeatureIDE.Test;

internal static class Utils
{
  
  public static bool IsValid(this ConfigurationPropagator @this) =>
    ((java.lang.Boolean)LongRunningWrapper.runMethod(@this.isValid())).booleanValue();

  public static bool CanBeValid(this ConfigurationPropagator @this) =>
    ((java.lang.Boolean)LongRunningWrapper.runMethod(@this.canBeValid())).booleanValue();

  public static ICollection<SelectableFeature> Update(this ConfigurationPropagator @this, bool redundantManual = true) =>
    ((java.util.Collection)LongRunningWrapper.runMethod(@this.update(redundantManual, null))).Cast<SelectableFeature>().ToArray();
}
