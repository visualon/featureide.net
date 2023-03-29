using de.ovgu.featureide.fm.core.@base;
using de.ovgu.featureide.fm.core.@base.impl;
using de.ovgu.featureide.fm.core.configuration;
using System.Collections.Generic;
using org.prop4j;

namespace VisualOn.FeatureIDE
{
  public static class FeatureModelFactory
  {
    private static readonly DefaultFeatureModelFactory FACTORY = DefaultFeatureModelFactory.getInstance();

    static FeatureModelFactory()
    {
      // suppress errors
      FMFactoryManager.getInstance().addExtension(DefaultFeatureModelFactory.getInstance());
      ConfigurationFactoryManager.getInstance().addExtension(DefaultConfigurationFactory.getInstance());
    }

    public static IFeatureStructure AddFeature(this IFeatureModel @this, string feature, bool @abstract = false)
    {
      Requires.NotNull(@this, nameof(@this));
      Requires.NotNull(feature, nameof(feature));

      var f = FACTORY.createFeature(@this, feature);

      @this.addFeature(f);

      var res = f.getStructure();

      if (@abstract)
      {
        res.setAbstract(true);
      }

      return res;
    }


    public static IConstraint AddConstraint(this IFeatureModel @this, Node rule)
    {
      Requires.NotNull(@this, nameof(@this));
      Requires.NotNull(rule, nameof(rule));

      var res = FACTORY.createConstraint(@this, rule);

      @this.addConstraint(res);

      return res;
    }

    public static IFeatureModel CreateModel() => FACTORY.create();

    public static IEnumerable<SelectableFeature> GetFeatures(this Configuration @this) => Requires.NotNull(@this, nameof(@this)).getFeatures().Cast<SelectableFeature>();

    public static IEnumerable<IFeature> GetSelectedFeatures(this Configuration @this) => Requires.NotNull(@this, nameof(@this)).getSelectedFeatures().Cast<IFeature>();

    public static bool? ToBool(this Selection @this)
    {
      if (@this == Selection.SELECTED)
      {
        return true;
      }

      if (@this == Selection.UNSELECTED)
      {
        return false;
      }

      return null;
    }

    public static Selection ToSel(this bool? @this)
    {
      if (@this.HasValue)
      {
        return @this.Value ? Selection.SELECTED : Selection.UNSELECTED;
      }

      return Selection.UNDEFINED;
    }
  }
}
