using de.ovgu.featureide.fm.core.analysis.cnf.formula;
using de.ovgu.featureide.fm.core.analysis.cnf.solver;
using de.ovgu.featureide.fm.core.@base;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace de.ovgu.featureide.fm.test
{
  internal class SolverTests
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

      var solver = new AdvancedSatSolver(formula.getCNF());

      Expect(solver.hasSolution()).To.Equal(ISimpleSatSolver.SatResult.TRUE);
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
