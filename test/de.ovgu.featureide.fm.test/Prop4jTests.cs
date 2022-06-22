using org.prop4j;
using org.prop4j.explain.solvers;

namespace de.ovgu.featureide.fm.test
{
  internal class Prop4jTests
  {
    private org.prop4j.explain.solvers.SatSolver solver;

    [SetUp]
    public void Setup()
    {
      solver = SatSolverFactory.getDefault().getSatSolver();
    }

    [Test]
    public void Simple()
    {
      var formula = new And();



      Expect(solver.isSatisfiable()).To.Be.True();

      solver.addFormula(formula);

      Expect(solver.isSatisfiable()).To.Be.True();
    }

    [Test]
    public void CanBeValid()
    {
      solver.addFormula(new Implies(new Literal("CORE1"), new Not(new Literal("CORE2"))));
      solver.addFormula(new Implies(new Literal("CORE2"), new Not(new Literal("CORE1"))));

      Expect(solver.isSatisfiable()).To.Be.True();


      var map = solver.getAssumptions();
      var m = solver.getModel();
      Console.WriteLine("assumptions: " + map.keySet().Cast<string>().ToArray());
    }
  }
}
