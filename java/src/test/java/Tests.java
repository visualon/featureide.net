import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.prop4j.And;
import org.prop4j.Implies;
import org.prop4j.Literal;
import org.prop4j.Not;
import org.prop4j.Or;

import de.ovgu.featureide.fm.core.analysis.cnf.formula.FeatureModelFormula;
import de.ovgu.featureide.fm.core.base.IFeatureModel;
import de.ovgu.featureide.fm.core.base.IFeatureStructure;
import de.ovgu.featureide.fm.core.configuration.Configuration;
import de.ovgu.featureide.fm.core.configuration.ConfigurationAnalyzer;
import de.ovgu.featureide.fm.core.configuration.Selection;

class Tests {
  private IFeatureModel model;
  private IFeatureStructure cores;
  private IFeatureStructure mods;
  private IFeatureStructure devs;

  @BeforeEach
  void BeforeEach() {
    model = Utils.CreateModel();
    var root = Utils.addFeature(model, "Root", true);
    root.setMandatory(true);
    model.getStructure().setRoot(root);

    cores = Utils.addFeature(model, "CoreModules", true);
    // change to alternate
    cores.setAlternative();
    cores.setMandatory(true);
    root.addChild(cores);

    mods = Utils.addFeature(model, "Modules", true);
    mods.setOr();
    root.addChild(mods);

    devs = Utils.addFeature(model, "Devices", true);
    mods.setOr();
    root.addChild(devs);
  }

  @Test
  void canBeValid() {
    cores.addChild(Utils.addFeature(model, "CORE1"));
    cores.addChild(Utils.addFeature(model, "CORE2"));

    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);

    configAnalyzer.update(true);

    System.out.println(formula.getCNFNode().toString());

    assertTrue(configAnalyzer.canBeValid(), "canbeValid");
    assertFalse(configAnalyzer.isValid(), "isValid");
  }

  @Test
  void shouldBeValid() {
    cores.addChild(Utils.addFeature(model, "CORE"));

    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);

    configAnalyzer.update(true);

    System.out.println(formula.getCNFNode().toString());

    assertTrue(configAnalyzer.canBeValid(), "canBeValid");
    assertTrue(configAnalyzer.isValid(), "isValid");

    var sfCore = config.getSelectableFeature("CORE");
    assertNotNull(sfCore);
    assertEquals(Selection.SELECTED, sfCore.getAutomatic(), "isAutoSelected");
  }

  @Test
  void complex() {
    cores.addChild(Utils.addFeature(model, "CORE"));
    cores.getFirstChild().setMandatory(true);

    mods.addChild(Utils.addFeature(model, "M1"));
    mods.addChild(Utils.addFeature(model, "M2"));
    mods.addChild(Utils.addFeature(model, "M3"));
    mods.addChild(Utils.addFeature(model, "M4"));

    devs.addChild(Utils.addFeature(model, "D1"));
    devs.addChild(Utils.addFeature(model, "D2"));
    devs.addChild(Utils.addFeature(model, "D3"));
    devs.addChild(Utils.addFeature(model, "D4"));

    Utils.add(model, new Implies(
        new Literal("M2"),
        new Not(
            new Literal("M3"))));

    Utils.add(model, new Implies(
        new Literal("D1"),
        new Not(
            new Literal("M3"))));

    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);

    configAnalyzer.update(true);

    System.out.println(formula.getCNFNode().toString());

    assertTrue(configAnalyzer.canBeValid(), "canBeValid");
    assertTrue(configAnalyzer.isValid(), "isValid");

    var sfCore = config.getSelectableFeature("CORE");
    assertNotNull(sfCore);
    assertEquals(Selection.SELECTED, sfCore.getAutomatic(), "isAutoSelected");
  }

  @Test
  void complex2() {
    cores.addChild(Utils.addFeature(model, "CORE"));

    mods.addChild(Utils.addFeature(model, "M1"));
    mods.addChild(Utils.addFeature(model, "M2"));
    mods.addChild(Utils.addFeature(model, "M3"));
    mods.addChild(Utils.addFeature(model, "M4"));

    devs.addChild(Utils.addFeature(model, "D1"));
    devs.addChild(Utils.addFeature(model, "D2"));
    devs.addChild(Utils.addFeature(model, "D3"));
    devs.addChild(Utils.addFeature(model, "D4"));

    Utils.add(model, new Implies(
      new Literal("CORE"),
      new Or(
        new And(new Literal("M4"), new Literal("M2")),
        new And(new Literal("M4"), new Literal("M3"))
      )
    ));

    Utils.add(model, new Implies(
        new Literal("M2"),
        new Not(
            new Literal("M3"))));

    Utils.add(model, new Implies(
        new Literal("D1"),
        new Not(
            new Literal("M3"))));

    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);

    configAnalyzer.update(true);

    System.out.println(formula.getCNFNode().toString());

    assertTrue(configAnalyzer.canBeValid(), "canBeValid");
    assertFalse(configAnalyzer.isValid(), "isValid");

    var sfCore = config.getSelectableFeature("CORE");
    assertNotNull(sfCore);
    assertEquals(Selection.SELECTED, sfCore.getAutomatic(), "isAutoSelected");

    var sfM4 = config.getSelectableFeature("M4");
    assertNotNull(sfM4);
    assertEquals(Selection.SELECTED, sfM4.getAutomatic(), "isAutoSelected");
  }

}
