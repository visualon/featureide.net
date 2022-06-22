import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
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

class AlternateModelTests {

  private IFeatureModel model;
  private IFeatureStructure root;

  @BeforeEach
  void BeforeEach() {
    model = Utils.CreateModel();
    root = Utils.addFeature(model, "Root", true);
    root.setMandatory(true);
    model.getStructure().setRoot(root);
  }

  @Test
  void simple() {
    root.addChild(Utils.addFeature(model, "CORE1"));
    root.addChild(Utils.addFeature(model, "CORE2"));
    root.changeToAlternative();

    var formula = new FeatureModelFormula(model);
    var config = new Configuration(formula);
    var configAnalyzer = new ConfigurationAnalyzer(formula, config);

    configAnalyzer.update(true);

    System.out.println(formula.getCNFNode().toString());

    assertTrue(configAnalyzer.canBeValid(), "canbeValid");
    assertFalse(configAnalyzer.isValid(), "isValid");
  }

  @Test
  void canBeValid() {
    root.addChild(Utils.addFeature(model, "CORE1"));
    root.addChild(Utils.addFeature(model, "CORE2"));

    Utils.add(model, new Or(
        new Literal("CORE1"),
        new Literal("CORE2")));
    Utils.add(model, new Implies(
        new Literal("CORE1"),
        new Not(
            new Literal("CORE2"))));
    Utils.add(model, new Implies(
        new Literal("CORE2"),
        new Not(
            new Literal("CORE1"))));

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
    root.addChild(Utils.addFeature(model, "CORE"));

    Utils.add(model, new Or(new Literal("CORE")));

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
}
