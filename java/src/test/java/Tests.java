import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.prop4j.Implies;
import org.prop4j.Literal;
import org.prop4j.Not;

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
  private FeatureModelFormula formula;
  private Configuration config;
  private ConfigurationAnalyzer configAnalyzer;

  @BeforeEach
  void BeforeEach() {
    model = Utils.CreateModel();
    var root = Utils.addFeature(model, "Root", true);
    root.setMandatory(true);
    model.getStructure().setRoot(root);

    cores = Utils.addFeature(model, "CoreModules", true);
    cores.changeToAlternative();
    cores.setMandatory(true);
    root.addChild(cores);

    mods = Utils.addFeature(model, "Modules", true);
    mods.changeToOr();
    root.addChild(mods);

    devs = Utils.addFeature(model, "Devices", true);
    devs.changeToOr();
    root.addChild(devs);

    formula = new FeatureModelFormula(model);
    config = new Configuration(formula);
    configAnalyzer = new ConfigurationAnalyzer(formula, config);
  }

  @Test
  void canBeValid() {
    cores.addChild(Utils.addFeature(model, "CORE1"));
    cores.addChild(Utils.addFeature(model, "CORE2"));

    formula.resetFormula();
    config.reset();

    configAnalyzer.update(true);

    assertTrue(configAnalyzer.canBeValid(), "canbeValid");
    assertFalse(configAnalyzer.isValid(), "isValid");
  }

  @Test
  void shouldBeValid() {
    cores.addChild(Utils.addFeature(model, "CORE"));

    formula.resetFormula();
    config.reset();

    configAnalyzer.update(true);

    assertTrue(configAnalyzer.canBeValid(), "canBeValid");
    assertTrue(configAnalyzer.isValid(), "isValid");

    var sfCore = config.getSelectableFeature("CORE");
    assertNotNull(sfCore);
    assertEquals(Selection.SELECTED, sfCore.getAutomatic(), "isAutoSelected");
  }

  @Test
  void complex() {
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
        new Literal("M2"),
        new Not(
            new Literal("M3"))));

    Utils.add(model, new Implies(
        new Literal("D1"),
        new Not(
            new Literal("M3"))));

    formula.resetFormula();
    config.reset();

    configAnalyzer.update(true);

    assertTrue(configAnalyzer.canBeValid(), "canBeValid");
    assertTrue(configAnalyzer.isValid(), "isValid");

    var sfCore = config.getSelectableFeature("CORE");
    assertNotNull(sfCore);
    assertEquals(Selection.SELECTED, sfCore.getAutomatic(), "isAutoSelected");
  }

}
