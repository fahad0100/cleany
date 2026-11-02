import 'dart:io';
import 'package:cleany/cleany.dart';
Future<void> main()async{
 const root='/Users/fahad/Documents/cleany/cleany';
 final project=Project('$root/flutter_example');
 final backup='$root/flutter_example_audit/acceptance_2_0_3_20261101/post_doctor';
 final plan=GenerationPlan(project);
 for(final path in [
  'lib/features/products/domain/repositories/products_repository.dart',
  'lib/features/products/data/repositories/products_repository_impl.dart',
  'lib/features/products/data/datasources/products_remote_data_source.dart',
  'lib/features/products/presentation/cubit/products_state.dart',
  'lib/features/products/presentation/cubit/products_cubit.dart',
  'lib/app/di/injection.dart','lib/app/composition/feature_pages.dart',
  'lib/app/router/app_router.dart','lib/app/router/route_names.dart','.cleany/features.json',
 ]){plan.writeBytes(path,File('$backup/$path').readAsBytesSync());}
 for(final name in ['audit_product_entity','audit_users_entity']){plan.delete('lib/features/products/domain/usecases/$name.dart');}
 final result=await GenerationTransaction(project,context:OperationContext(onProgress:(e)=>print('${e.command??e.stage}: ${e.detail??''}'))).apply(plan);
 print('Temporary action cleanup: ${result.status.name}');
}
