using org.prop4j;
using org.prop4j.explain.solvers;

namespace VisualOn.FeatureIDE.Test;

internal class Prop4jTests
{
  private org.prop4j.explain.solvers.SatSolver? solver;

  [SetUp]
  public void Setup()
  {
    solver = SatSolverFactory.getDefault().getSatSolver();
  }

  [Test]
  public void Simple()
  {
    var formula = new And();

    Assert.That(solver, Is.Not.Null);

    Expect(solver.isSatisfiable()).To.Be.True();

    solver.addFormula(formula);

    Expect(solver.isSatisfiable()).To.Be.True();
  }

  [Test]
  public void CanBeValid()
  {
    Assert.That(solver, Is.Not.Null);

    solver.addFormula(new Implies(new Literal("CORE1"), new Not(new Literal("CORE2"))));
    solver.addFormula(new Implies(new Literal("CORE2"), new Not(new Literal("CORE1"))));

    Expect(solver.isSatisfiable()).To.Be.True();


    var map = solver.getAssumptions();
    var m = solver.getModel();
    Console.WriteLine("assumptions: " + string.Join(",", map.keySet().Cast<string>().ToArray()));
  }
}
