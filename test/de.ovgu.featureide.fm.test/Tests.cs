using de.ovgu.featureide.fm.core.analysis.cnf.formula;
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
    cores.setAlternative();
    cores.setMandatory(true);
    root.addChild(cores);

    mods = model.AddFeature("Modules", true);
    mods.setOr();
    root.addChild(mods);

    devs = model.AddFeature("Devices", true);
    devs.setOr();
    root.addChild(devs);
  }

  [Test]
  public void CanBeValid()
  {
    var core1 = model.AddFeature("CORE1");
    var core2 = model.AddFeature("CORE2");
    cores.addChild(core1);
    cores.addChild(core2);

    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);

    var sCore1 = config.getSelectableFeature("CORE1");
    var sCore2 = config.getSelectableFeature("CORE2");

    configAnalyzer.update(true);

    Expect(configAnalyzer.canBeValid()).To.Be.True("canBeValid");
    Expect(configAnalyzer.isValid()).To.Be.False("isValid");

    Expect(sCore1?.getAutomatic()?.name()).To.Equal(Selection.UNDEFINED.name(), "isAutoSelected");
    Expect(sCore2?.getAutomatic()?.name()).To.Equal(Selection.UNDEFINED.name(), "isAutoSelected");
  }

  [Test]
  public void ShouldBeValid()
  {
    cores.addChild(model.AddFeature("CORE"));

    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);

    var sCore = config.getSelectableFeature("CORE");

    configAnalyzer.update(true);

    Expect(configAnalyzer.canBeValid()).To.Be.True("canBeValid");
    Expect(configAnalyzer.isValid()).To.Be.True("isValid");

    Expect(sCore?.getAutomatic()?.name()).To.Equal(Selection.SELECTED.name(), "isAutoSelected");
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


    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);
    var sCore = config.getSelectableFeature("CORE");

    configAnalyzer.update(true);

    Expect(configAnalyzer.canBeValid()).To.Be.True("canBeValid");
    Expect(configAnalyzer.isValid()).To.Be.True("isValid");
    Expect(sCore?.getAutomatic()?.name()).To.Equal(Selection.SELECTED.name(), "isAutoSelected");
  }



  [Test]
  public void Complex2()
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


    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);
    var sCore = config.getSelectableFeature("CORE");
    var sm4 = config.getSelectableFeature("M4");

    configAnalyzer.update(true);

    Expect(configAnalyzer.canBeValid()).To.Be.True("canBeValid");
    Expect(configAnalyzer.isValid()).To.Be.False("isValid");

    Expect(sCore?.getAutomatic()?.name()).To.Equal(Selection.SELECTED.name(), "isAutoSelected");
    Expect(sm4?.getAutomatic()?.name()).To.Equal(Selection.SELECTED.name(), "isAutoSelected");
  }
}
