using de.ovgu.featureide.fm.core.@base;
using de.ovgu.featureide.fm.core.configuration;
using org.prop4j;

namespace de.ovgu.featureide.fm.test;

public class Tests
{
  private IFeatureModel model;
  private IFeatureStructure cores;
  private IFeatureStructure mods;
  private IFeatureStructure devs;

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

    mods = model.AddFeature("Modules", true);
    mods.changeToOr();
    root.addChild(mods);

    devs = model.AddFeature("Devices", true);
    devs.changeToOr();
    root.addChild(devs);
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

  [Test]
  public void Complex()
  {
    cores.addChild(model.AddFeature("CORE"));

    mods.addChild(model.AddFeature("M1"));
    mods.addChild(model.AddFeature("M2"));
    mods.addChild(model.AddFeature("M3"));
    mods.addChild(model.AddFeature("M4"));

    devs.addChild(model.AddFeature("D1"));
    devs.addChild(model.AddFeature("D2"));
    devs.addChild(model.AddFeature("D3"));
    devs.addChild(model.AddFeature("D4"));

    model.Add(new Implies(
      new Literal("CORE"),
      new Or(
        new And(new Literal("M4"), new Literal("M2")),
        new And(new Literal("M4"), new Literal("M3"))
      )
    ));

    model.Add(new Implies(
      new Literal("M2"),
      new Not(
        new Literal("M3")
      )
    ));

    model.Add(new Implies(
      new Literal("D1"),
      new Not(
        new Literal("M3")
      )
    ));

    var config = new Configuration(model, false);
    var sCore = config.GetFeatures().FirstOrDefault(sf => sf.getName() == "CORE");
    var sm4 = config.GetFeatures().FirstOrDefault(sf => sf.getName() == "M4");

    config.setPropagate(true);
    config.update(true, null);

    Expect(config.isValid()).To.Be.False();
    Expect(config.canBeValid()).To.Be.True();
    Expect(sCore?.getAutomatic()).To.Equal(Selection.SELECTED);
    Expect(sCore?.getSelection()).To.Equal(Selection.SELECTED);
    Expect(sm4?.getAutomatic()).To.Equal(Selection.SELECTED);
    Expect(sm4?.getSelection()).To.Equal(Selection.SELECTED);
  }
}
