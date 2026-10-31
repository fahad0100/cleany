import 'dart:io';

import 'package:cleany/src/ast_editor.dart';

void main(List<String> args) {
  final root = args.single;
  final names = File('$root/lib/app/router/route_names.dart');
  names.writeAsStringSync(
    names.readAsStringSync().replaceAll("'/home'", "'/sign-in'"),
  );
  final di = File('$root/lib/app/di/injection.dart');
  final editor = AstEditor(
    di.readAsStringSync().replaceAll(
      'HomeCubit(container<GetHome>())',
      'HomeCubit(GetHome(container<HomeRepository>()))',
    ),
  )..removeRegistrations({'GetHome'});
  di.writeAsStringSync(editor.source);
  final router = File('$root/lib/app/router/app_router.dart');
  router.writeAsStringSync(
    (AstEditor(router.readAsStringSync())..removeRoutes({'home'})).source,
  );
  File('$root/lib/features/home/presentation/pages/home_page.dart')
      .deleteSync();
}
