import 'package:cleany/content/core_files/constants/app_colors.dart';
import 'package:cleany/content/core_files/constants/app_enums.dart';
import 'package:cleany/content/core_files/constants/app_icons.dart.dart';
import 'package:cleany/content/core_files/constants/app_images.dart';
import 'package:cleany/content/core_files/di/configure_dependencies.dart';
import 'package:cleany/content/core_files/di/third_part.dart';
import 'package:cleany/content/core_files/errors/failure.dart';
import 'package:cleany/content/core_files/errors/network_exceptions.dart';
import 'package:cleany/content/core_files/extensions/color_extensions.dart';
import 'package:cleany/content/core_files/extensions/context_extensions.dart';
import 'package:cleany/content/core_files/extensions/string_extensions.dart';
import 'package:cleany/content/core_files/navigation/app_router.dart';
import 'package:cleany/content/core_files/navigation/routes.dart';
import 'package:cleany/content/core_files/network/api_endpoints.dart';
import 'package:cleany/content/core_files/network/dio_client.dart';
import 'package:cleany/content/core_files/services/app_device_utils.dart';
import 'package:cleany/content/core_files/services/local_keys_service.dart';
import 'package:cleany/content/core_files/setup.dart';
import 'package:cleany/content/core_files/theme/app_text_theme.dart';
import 'package:cleany/content/core_files/theme/app_theme.dart';
import 'package:cleany/content/core_files/global/cubit/public_cubit.dart';
import 'package:cleany/content/core_files/global/cubit/public_state.dart';
import 'package:cleany/content/core_files/utils/formatters.dart';
import 'package:cleany/content/core_files/utils/validators.dart';
import 'package:cleany/content/core_files/widgets/loading_widget.dart';

String returnFileCoreContent({required String fileName}) {
  //--------------------------constants-----------------------------

  if (fileName.contains('app_colors.dart')) {
    return appColorsFile();
  }
  if (fileName.contains('app_images.dart')) {
    return appImagesFile();
  }
  if (fileName.contains('app_enums.dart')) {
    return appEnumsFile();
  }
  if (fileName.contains('app_icons.dart')) {
    return appIconsFile();
  }
  //--------------------------di-----------------------------

  if (fileName.contains('third_part.dart')) {
    return thirdPartyFile();
  }

  if (fileName.contains('configure_dependencies.dart')) {
    return configureDependencies();
  }

  //--------------------------errors--------------------------
  if (fileName.contains('failure.dart')) {
    return failureFile();
  }
  if (fileName.contains('exceptions.dart')) {
    return exceptionsFile();
  }
  //--------------------------extensions-----------------------------
  if (fileName.contains('context_extensions.dart')) {
    return contextExtensionsFile();
  }
  if (fileName.contains('string_extensions.dart')) {
    return stringExtensionsFile();
  }
  if (fileName.contains('color_extensions.dart')) {
    return colorExtensionsFile();
  }
  //--------------------------global-----------------------------
  if (fileName.contains('public_cubit.dart')) {
    return createGlobalCubitFile();
  }
  if (fileName.contains('public_state.dart')) {
    return createGlobalStateFile();
  }
  //--------------------------navigation-----------------------------
  if (fileName.contains('app_router.dart')) {
    return appRoutesFile();
  }
  if (fileName.contains('routers.dart')) {
    return routesFile();
  }
  //--------------------------network-----------------------------
  if (fileName.contains('dio_client.dart')) {
    return dioClientFile();
  }

  if (fileName.contains('api_endpoints.dart')) {
    return apiEndpointsFile();
  }

  //--------------------------services-----------------------------
  if (fileName.contains('app_device_utils.dart')) {
    return appDeviceUtilsFile();
  }
  if (fileName.contains('local_keys_service.dart')) {
    return localKeysServiceFile();
  }
  //--------------------------theme-----------------------------
  if (fileName.contains('app_theme.dart')) {
    return appThemeFile();
  }
  if (fileName.contains('app_text_theme.dart')) {
    return appTextThemeFile();
  }
  //--------------------------utils-----------------------------
  if (fileName.contains('validators.dart')) {
    return validatorsFile();
  }
  if (fileName.contains('formatters.dart')) {
    return formattersFile();
  }
  //--------------------------widgets-----------------------------
  if (fileName.contains('loading_widget.dart')) {
    return loadingWidgetFile();
  }
  //--------------------------setup-----------------------------
  if (fileName.contains('setup.dart')) {
    return setupFile();
  }

  return '// TODO: Implement $fileName\n';
}
