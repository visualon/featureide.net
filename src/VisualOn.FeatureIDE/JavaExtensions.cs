using java.lang;
using System.Collections.Generic;

namespace VisualOn.FeatureIDE;

public static class JavaExtensions
{
  public static IEnumerable<T> Cast<T>(this Iterable @this)
  {
    Requires.NotNull(@this, nameof(@this));
    for (var it = @this.iterator(); it.hasNext();)
    {
      yield return (T)it.next();
    }
  }
}
