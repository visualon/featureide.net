using de.ovgu.featureide.fm.core.@base;
using de.ovgu.featureide.fm.core.configuration;

namespace de.ovgu.featureide.fm.test;

public class Tests
{
  private IFeatureModel model;
  private IFeatureStructure cores;

  [SetUp]
  public void Setup()
  {
    model = Utils.CreateModel();
    var root = model.AddFeature("Root", true);
    root.setMandatory(true);
    model.getStructure().setRoot(root);

    cores = model.AddFeature("CoreModules", true);
    cores.changeToAlternative();
    cores.setMandatory(true);
    root.addChild(cores);
  }

  [Test]
  public void CanBeValid()
  {
    var core1 = model.AddFeature("CORE1");
    var core2 = model.AddFeature("CORE2");
    cores.addChild(core1);
    cores.addChild(core2);

    var config = new Configuration(model, false);

    config.setPropagate(true);
    config.update(true, null);

    Expect(config.isValid()).To.Be.False();
    Expect(config.canBeValid()).To.Be.True();
  }



  [Test]
  public void ShouldBeValid()
  {
    var core1 = model.AddFeature("CORE1");
    cores.addChild(core1);

    var config = new Configuration(model, false);
    var sCore = config.GetFeatures().FirstOrDefault(sf => sf.getName() == "CORE1");

    config.setPropagate(true);
    config.update(true, null);

    Expect(config.isValid()).To.Be.True();
    Expect(config.canBeValid()).To.Be.True();
    Expect(sCore?.getAutomatic()).To.Equal(Selection.SELECTED);
    Expect(sCore?.getSelection()).To.Equal(Selection.SELECTED);
  }
}
