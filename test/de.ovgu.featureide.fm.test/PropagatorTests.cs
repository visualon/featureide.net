using de.ovgu.featureide.fm.core.analysis.cnf;
using de.ovgu.featureide.fm.core.analysis.cnf.analysis;
using de.ovgu.featureide.fm.core.analysis.cnf.formula;
using de.ovgu.featureide.fm.core.analysis.cnf.solver;
using de.ovgu.featureide.fm.core.@base;
using de.ovgu.featureide.fm.core.configuration;
using de.ovgu.featureide.fm.core.job;
using java.util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace de.ovgu.featureide.fm.test
{
  internal class PropagatorTests
  {
    private IFeatureModel model;
    private IFeatureStructure cores;
    private IFeatureStructure mods;
    private IFeatureStructure devs;
    private FeatureModelFormula formula;

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


      formula = new FeatureModelFormula(model);
    }

    [Test]
    public void ShouldBeValid()
    {
      cores.addChild(model.AddFeature("CORE1"));

      var config = new Configuration(formula);
      var rootNode = formula.getCNF();
      var analysis = new CoreDeadAnalysis(rootNode);

      var manualLiterals = new ArrayList();
      var manualLiteralSet = new HashSet(manualLiterals);

      var intLiterals = new int[manualLiterals.size()];
      for (int i = 0; i < intLiterals.Length; i++)
      {
        intLiterals[i] = (int)manualLiterals.get(i);
      }

      Expect(intLiterals).To.Be.Empty();

      analysis.setAssumptions(new LiteralSet(intLiterals));
      var impliedFeatures = LongRunningWrapper.runMethod(analysis) as LiteralSet;

      Expect(impliedFeatures).To.Not.Be.Null();
      Expect(impliedFeatures.size()).To.Equal(2);

      var result = new HashSet(rootNode.getVariables().size());

      foreach (var i in impliedFeatures.getLiterals())
      {
         SelectableFeature feature = config.getSelectableFeature(rootNode.getVariables().getName(i));
        if (feature != null)
        {
          Console.WriteLine(feature.getName() + ": " + i);
          config.setAutomatic(feature, i > 0 ? Selection.SELECTED : Selection.UNSELECTED);
          result.add(feature);
          manualLiteralSet.add(feature.getManual() == Selection.SELECTED ? i : -i);
        }
      }


      Expect(manualLiteralSet.size()).To.Equal(2);
      Expect(result.size()).To.Equal(2);

      var updateFeatures = new ArrayList();
      foreach ( SelectableFeature feature in config.getFeatures().Cast<SelectableFeature>())
      {
        if (!manualLiteralSet
            .contains(rootNode.getVariables().getVariable(feature.getFeature().getName(), feature.getManual() == Selection.SELECTED)))
        {
          updateFeatures.add(feature);
          result.add(feature);
        }
      }

      Expect(result.size()).To.Equal(5);

      var solver = new AdvancedSatSolver(formula.getCNF());

      foreach ( int feature in intLiterals)
      {
        solver.assignmentPush(feature);
      }

      Expect(solver.getAssignmentSize()).To.Equal(0);
    }



    [Test]
    public void CanBeValid()
    {
      cores.addChild(model.AddFeature("CORE1"));
      cores.addChild(model.AddFeature("CORE2"));

      var solver = new AdvancedSatSolver(formula.getCNF());

      Expect(solver.hasSolution()).To.Equal(ISimpleSatSolver.SatResult.TRUE);
    }
  }
}
