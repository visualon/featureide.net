
function ThrowOnNativeFailure {
  if (-not $?) {
    throw 'Native Failure'
  }
}
