String fontExtensionsFile() {
  return '''
import 'package:sizer/sizer.dart';

extension ResponsiveFontSizer on num {
  double font({double baseWidth = 375, double min = 10, double? max}) {
    final screenWidth = 100.w;

    final scaled = (this * screenWidth) / baseWidth;

    if (max != null) {
      return scaled.clamp(min, max);
    }

    return scaled < min ? min : scaled;
  }

  double sizeSW({double? min, double? max}) {
    // Get screen width using ScreenUtil
    final screenWidth = 100.sw; // 1.sw يعطي كامل عرض الشاشة

    // Scale this number relative to 100 as full width
    final scaled = (this / 100) * screenWidth;

    // Apply min/max constraints if provided
    if (min != null && max != null) {
      return scaled.clamp(min, max);
    } else if (min != null) {
      return scaled < min ? min : scaled;
    } else if (max != null) {
      return scaled > max ? max : scaled;
    }

    return scaled;
  }

  /// Height based on screen height
  double sizeSH({double? min, double? max}) {
    final screenHeight = 100.sh;

    // Scale this number relative to 100 as full width
    final scaled = (this / 100) * screenHeight;

    // Apply min/max constraints if provided
    if (min != null && max != null) {
      return scaled.clamp(min, max);
    } else if (min != null) {
      return scaled < min ? min : scaled;
    } else if (max != null) {
      return scaled > max ? max : scaled;
    }

    return scaled;
  }
}


''';
}
