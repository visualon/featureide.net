using org.prop4j;

namespace de.ovgu.featureide.fm.test
{
  internal class Prop4jTests
  {
    private readonly long Timeout = (long)TimeSpan.FromSeconds(5).TotalMilliseconds;

    [SetUp]
    public void Setup()
    {
    }

    [Test]
    public void Simple()
    {
      var formula = new And();

      var solver = new SatSolver(formula, Timeout);

      Expect(solver.isSatisfiable()).To.Be.True();
    }

    [Test]
    public void CanBeValid()
    {
      var formula = new And(
        new Implies(new Literal("CORE1"), new Not(new Literal("CORE2"))),
        new Implies(new Literal("CORE2"), new Not(new Literal("CORE1")))
      );
      var solver = new SatSolver(formula, Timeout);

      Expect(solver.isSatisfiable()).To.Be.True();
    }
  }
}
