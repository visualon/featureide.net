using org.prop4j;
using de.ovgu.featureide.fm.core.@base;
using de.ovgu.featureide.fm.core.@base.impl;
using de.ovgu.featureide.fm.core.configuration;
using java.lang;
using de.ovgu.featureide.fm.core.job;

namespace de.ovgu.featureide.fm.test
{
  internal static class Utils
  {
    private static readonly DefaultFeatureModelFactory FACTORY = new();

    public static IFeatureStructure AddFeature(this IFeatureModel @this, string feature, bool @abstract = false)
    {
      var f = FACTORY.createFeature(@this, feature);

      @this.addFeature(f);

      var res = f.getStructure();

      if (@abstract)
      {
        res.setAbstract(true);
      }

      return res;
    }

    public static IFeatureModel CreateModel() => FACTORY.createFeatureModel();
    public static IEnumerable<SelectableFeature> GetFeatures(this Configuration @this) => @this.getFeatures().Cast<SelectableFeature>();

    public static IEnumerable<T> Cast<T>(this Iterable @this)
    {
      for (var it = @this.iterator(); it.hasNext();)
      {
        yield return (T)it.next();
      }
    }

    public static IConstraint Add(this IFeatureModel @this, Node rule)
    {
      var res = FACTORY.createConstraint(@this, rule);

      @this.addConstraint(res);

      return res;
    }

    public static bool IsValid(this ConfigurationPropagator @this) =>
      ((java.lang.Boolean)LongRunningWrapper.runMethod(@this.isValid())).booleanValue();

    public static bool CanBeValid(this ConfigurationPropagator @this) =>
      ((java.lang.Boolean)LongRunningWrapper.runMethod(@this.canBeValid())).booleanValue();

    public static ICollection<SelectableFeature> Update(this ConfigurationPropagator @this, bool redundantManual = true) =>
      ((java.util.Collection)LongRunningWrapper.runMethod(@this.update(redundantManual, null))).Cast<SelectableFeature>().ToArray();
  }
}
