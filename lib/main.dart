import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sizer/sizer.dart';
import 'core/global/cubit/public_cubit.dart';
import 'core/global/cubit/public_state.dart';
import 'core/setup.dart';
import 'core/theme/app_theme.dart';
import 'core/di/configure_dependencies.dart';
import 'core/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setup();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'AR')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GlobalCubit(GetIt.I.get(), GetIt.I.get())..load(context: context),
      child: Builder(
        builder: (context) {
          return Builder(
            builder: (context) {
              return Sizer(
                builder: (context, orientation, screenType) {
                  return BlocBuilder<GlobalCubit, ChangeState>(
                    builder: (context, state) {
                      return MaterialApp.router(
                        routerConfig: AppRouter.router,
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: context.locale,
                        themeMode: state.themeMode,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        debugShowCheckedModeBanner: true,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

