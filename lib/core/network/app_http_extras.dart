/// Keys for [Options.extra] consumed by [AppHttpClient] interceptors.
abstract final class AppHttpExtras {
  /// When true, [AppApiLoadingController] is not incremented (lightweight search).
  static const String quietNetwork = 'quiet_network';
}
