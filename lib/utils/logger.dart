class Logger {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String cyan = '\x1B[36m';

  static void success(String msg) {
    print("$_green $msg$_reset");
  }

  static void error(String msg) {
    print("$_red✖ $msg$_reset");
  }

  static void warning(String msg) {
    print("$_yellow⚠ $msg$_reset");
  }

  static void info(String msg) {
    print("$cyan$msg$_reset");
  }
}
