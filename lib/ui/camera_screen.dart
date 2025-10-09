// Conditional export: use IO implementation on mobile/desktop, Web implementation on Flutter Web.
export 'camera_screen_io.dart' if (dart.library.io) 'camera_screen_web.dart';