import org.prop4j.Node;

import de.ovgu.featureide.fm.core.base.IConstraint;
import de.ovgu.featureide.fm.core.base.IFeatureModel;
import de.ovgu.featureide.fm.core.base.IFeatureStructure;
import de.ovgu.featureide.fm.core.base.impl.ConfigurationFactoryManager;
import de.ovgu.featureide.fm.core.base.impl.DefaultConfigurationFactory;
import de.ovgu.featureide.fm.core.base.impl.DefaultFeatureModelFactory;

public class Utils {

  private static DefaultFeatureModelFactory FACTORY = new DefaultFeatureModelFactory();

  static {
    ConfigurationFactoryManager.getInstance().addExtension(DefaultConfigurationFactory.getInstance());
  }

  public static IFeatureModel CreateModel() {
    return FACTORY.create();
  }

  public static IFeatureStructure addFeature(IFeatureModel self, String feature) {
    return addFeature(self, feature, false);
  }

  public static IFeatureStructure addFeature(IFeatureModel self, String feature, boolean abstractFeature) {
    var f = FACTORY.createFeature(self, feature);

    self.addFeature(f);

    var res = f.getStructure();

    if (abstractFeature) {
      res.setAbstract(true);
    }

    return res;
  }

  public static IConstraint add(IFeatureModel self, Node rule) {
    var res = FACTORY.createConstraint(self, rule);

    self.addConstraint(res);

    return res;
  }
}
