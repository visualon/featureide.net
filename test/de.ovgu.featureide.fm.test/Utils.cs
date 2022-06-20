using org.prop4j;
using de.ovgu.featureide.fm.core.@base;
using de.ovgu.featureide.fm.core.@base.impl;
using de.ovgu.featureide.fm.core.configuration;
using java.lang;

namespace de.ovgu.featureide.fm.test
{
  internal static class Utils
  {
    private static readonly IFeatureModelFactory FACTORY = FMFactoryManager.getDefaultFactory();

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
  }
}
