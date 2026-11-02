from pathlib import Path
import json
OUT=Path('/private/tmp/cleany_store_sources')
def put(path,code):
 p=OUT/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(code.strip()+'\n')
def entity(feature,body):
 put(f'lib/features/{feature}/domain/entities/{feature}_entity.dart',f"""// Immutable business data; transport DTOs stay in Data.
import 'package:freezed_annotation/freezed_annotation.dart';
part '{feature}_entity.freezed.dart';
{body}
""")
entity('products', '''@freezed
abstract class ProductsEntity with _$ProductsEntity {
 const factory ProductsEntity({required int id, required String title, required double price,
 required String description, required String category, required String image,
 @Default(0) double rating, @Default(0) int reviewCount}) = _ProductsEntity;
}''')
entity('carts', '''@freezed
abstract class CartsEntity with _$CartsEntity {
 const factory CartsEntity({required int id, required int userId, required DateTime date,
 required List<CartLineEntity> products}) = _CartsEntity;
}
@freezed
abstract class CartLineEntity with _$CartLineEntity {
 const factory CartLineEntity({required int productId, required int quantity,
 @Default('') String title, @Default('') String image, @Default(0) double unitPrice}) = _CartLineEntity;
}''')
put('lib/features/carts/domain/entities/cart_draft.dart', '''/// A business request, independent of HTTP and JSON.
class CartDraft {
 const CartDraft({required this.productId, this.quantity = 1, this.userId = 1});
 final int productId;
 final int quantity;
 final int userId;
}''')
entity('users', '''@freezed
abstract class UsersEntity with _$UsersEntity {
 const factory UsersEntity({required int id, required String username, required String email,
 required String firstName, required String lastName, required String phone,
 required String city, required String street, required String zipcode}) = _UsersEntity;
}''')
entity('auth', '''@Freezed(toStringOverride: false)
abstract class AuthEntity with _$AuthEntity {
 const AuthEntity._();
 const factory AuthEntity({required String token, required String username, required int userId}) = _AuthEntity;
 @override
 String toString() => 'AuthEntity(userId: $userId, authenticated: ${token.isNotEmpty})';
}''')
models={
'products':'''@freezed
abstract class ProductsModel with _$ProductsModel {
 const factory ProductsModel({required int id, required String title, required double price,
 required String description, required String category, required String image,
 required RatingModel rating}) = _ProductsModel;
 factory ProductsModel.fromJson(Map<String,dynamic> json) => _$ProductsModelFromJson(json);
}
@freezed
abstract class RatingModel with _$RatingModel {
 const factory RatingModel({required double rate, required int count}) = _RatingModel;
 factory RatingModel.fromJson(Map<String,dynamic> json) => _$RatingModelFromJson(json);
}''',
'carts':'''@freezed
abstract class CartsModel with _$CartsModel {
 const factory CartsModel({required int id, required int userId, required DateTime date,
 required List<CartProductModel> products}) = _CartsModel;
 factory CartsModel.fromJson(Map<String,dynamic> json) => _$CartsModelFromJson(json);
}
@freezed
abstract class CartProductModel with _$CartProductModel {
 const factory CartProductModel({required int productId, required int quantity}) = _CartProductModel;
 factory CartProductModel.fromJson(Map<String,dynamic> json) => _$CartProductModelFromJson(json);
}''',
'users':'''@freezed
abstract class UsersModel with _$UsersModel {
 const factory UsersModel({required int id, required String email, required String username,
 required UserNameModel name, required UserAddressModel address, required String phone}) = _UsersModel;
 factory UsersModel.fromJson(Map<String,dynamic> json) => _$UsersModelFromJson(json);
}
@freezed
abstract class UserNameModel with _$UserNameModel {
 const factory UserNameModel({required String firstname, required String lastname}) = _UserNameModel;
 factory UserNameModel.fromJson(Map<String,dynamic> json) => _$UserNameModelFromJson(json);
}
@freezed
abstract class UserAddressModel with _$UserAddressModel {
 const factory UserAddressModel({required String city, required String street, required String zipcode}) = _UserAddressModel;
 factory UserAddressModel.fromJson(Map<String,dynamic> json) => _$UserAddressModelFromJson(json);
}''',
'auth':'''@Freezed(toStringOverride: false)
abstract class AuthModel with _$AuthModel {
 const factory AuthModel({required String token}) = _AuthModel;
 factory AuthModel.fromJson(Map<String,dynamic> json) => _$AuthModelFromJson(json);
}'''}
for f,body in models.items():
 put(f'lib/features/{f}/data/models/{f}_model.dart',f"""// The API's JSON shape; conversion to Domain belongs to the repository.
import 'package:freezed_annotation/freezed_annotation.dart';
part '{f}_model.freezed.dart';
part '{f}_model.g.dart';
{body}""")
# Keep Retrofit clients in the Core folder scaffolded by Cleany.
apis={
'products':"@GET('/products') Future<List<Map<String,dynamic>>> fetch();\n @GET('/products/1') Future<Map<String,dynamic>> getFeaturedProduct();",
'carts':"@GET('/carts') Future<List<Map<String,dynamic>>> fetch();\n @POST('/carts') Future<Map<String,dynamic>> createCart(@Body() Map<String,dynamic> body);\n @DELETE('/carts/{id}') Future<Map<String,dynamic>> deleteCart(@Path('id') int id);",
'users':"@GET('/users') Future<List<Map<String,dynamic>>> fetch();\n @GET('/users/{id}') Future<Map<String,dynamic>> getUserProfile(@Path('id') int id);",
'auth':"@POST('/auth/login') Future<Map<String,dynamic>> signIn(@Body() Map<String,dynamic> body);\n @GET('/users') Future<List<Map<String,dynamic>>> users();"}
for f,methods in apis.items():
 t=f.title();put(f'lib/core/network/retrofit/{f}_api.dart',f"""// Typed endpoints for the public Fake Store API. Returns raw transport JSON.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part '{f}_api.g.dart';
@RestApi()
abstract class {t}Api {{
 factory {t}Api(Dio dio, {{String? baseUrl}}) = _{t}Api;
 {methods}
}}""")
datasources={
'products':"Future<List<Map<String,dynamic>>> fetch() => _api.fetch();\n Future<Map<String,dynamic>> getFeaturedProduct() => _api.getFeaturedProduct();",
'carts':"Future<List<Map<String,dynamic>>> fetch() => _api.fetch();\n Future<Map<String,dynamic>> createCart(Map<String,dynamic> body) => _api.createCart(body);\n Future<void> deleteCart(int id) async { await _api.deleteCart(id); }",
'users':"Future<List<Map<String,dynamic>>> fetch() => _api.fetch();\n Future<Map<String,dynamic>> getUserProfile(int id) => _api.getUserProfile(id);",
'auth':"Future<Map<String,dynamic>> signIn(String username, String password) => _api.signIn({'username': username, 'password': password});\n Future<List<Map<String,dynamic>>> users() => _api.users();"}
for f,methods in datasources.items():
 t=f.title();put(f'lib/features/{f}/data/datasources/{f}_remote_data_source.dart',f"""// Raw JSON only: no Entity mapping and no Failure conversion here.
import 'package:cleany_store/core/network/retrofit/{f}_api.dart';
class {t}RemoteDataSource {{
 const {t}RemoteDataSource(this._api);
 final {t}Api _api;
 {methods}
}}""")
put('lib/core/storage/session_store.dart', '''import 'package:flutter/foundation.dart';
import 'package:cleany_store/features/auth/domain/entities/auth_entity.dart';
/// This demo keeps the session in memory only. Passwords are never retained.
class SessionStore extends ValueNotifier<AuthEntity?> {
 SessionStore() : super(null);
 void signIn(AuthEntity session) { value = session; }
 void signOut() { value = null; }
}''')
put('lib/app/config/store_preferences.dart', '''import 'package:flutter/material.dart';
/// UI preferences are separate from authentication and business data.
class StorePreferences extends ChangeNotifier {
 Locale locale = const Locale('en');
 void toggleLanguage() { locale = Locale(locale.languageCode == 'en' ? 'ar' : 'en'); notifyListeners(); }
}''')
# Shared repository contracts: operations added through Cleany stay on this contract.
contracts={
'products':"Future<Result<List<ProductsEntity>,Failure>> fetch();\n Future<Result<ProductsEntity,Failure>> getFeaturedProduct();",
'carts':"Future<Result<List<CartsEntity>,Failure>> fetch();\n Future<Result<CartsEntity,Failure>> createCart(CartDraft draft);\n Future<Result<void,Failure>> deleteCart(int id);",
'users':"Future<Result<List<UsersEntity>,Failure>> fetch();\n Future<Result<UsersEntity,Failure>> getUserProfile(int id);",
'auth':"Future<Result<AuthEntity,Failure>> fetch();\n Future<Result<AuthEntity,Failure>> signIn({required String username, required String password});\n Future<Result<void,Failure>> signOut();"}
for f,methods in contracts.items():
 t=f.title(); extra="import '../entities/cart_draft.dart';" if f=='carts' else ''
 put(f'lib/features/{f}/domain/repositories/{f}_repository.dart',f"""import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import '../entities/{f}_entity.dart';
{extra}
/// Business contract shared by all operations on this feature.
abstract interface class {t}Repository {{ {methods} }}""")
put('lib/core/errors/repository_guard.dart', '''import 'package:multiple_result/multiple_result.dart';
import '../network/failure_mapper.dart';
import 'failure.dart';
import 'error_reporter.dart';
/// Exactly one transport-to-Failure boundary; diagnostics cannot break Result.
Future<Result<T,Failure>> repositoryGuard<T>(Future<T> Function() run, ErrorReporter report) async {
 try { return Success(await run()); } catch (error, stack) {
  final failure = mapFailure(error);
  if (failure is UnexpectedFailure) { try { report(error, stack); } catch (_) { /* Preserve Result. */ } }
  return Error(failure);
 }
}''')
for f in ['products','carts','users','auth']:
 t=f.title();extra="import '../../domain/entities/cart_draft.dart';" if f=='carts' else ''
 if f=='auth':extra+="\nimport 'package:cleany_store/core/storage/session_store.dart';"
 if f=='products':
  methods='''ProductsEntity _entity(ProductsModel m) => ProductsEntity(id:m.id,title:m.title,price:m.price,description:m.description,category:m.category,image:m.image,rating:m.rating.rate,reviewCount:m.rating.count);
 @override Future<Result<List<ProductsEntity>,Failure>> fetch() => repositoryGuard(() async => (await _remote.fetch()).map((j)=>_entity(ProductsModel.fromJson(j))).toList(),reportError);
 @override Future<Result<ProductsEntity,Failure>> getFeaturedProduct() => repositoryGuard(() async => _entity(ProductsModel.fromJson(await _remote.getFeaturedProduct())),reportError);'''
 elif f=='carts':
  methods='''CartsEntity _entity(CartsModel m) => CartsEntity(id:m.id,userId:m.userId,date:m.date,products:m.products.map((p)=>CartLineEntity(productId:p.productId,quantity:p.quantity)).toList());
 @override Future<Result<List<CartsEntity>,Failure>> fetch() => repositoryGuard(() async => (await _remote.fetch()).map((j)=>_entity(CartsModel.fromJson(j))).toList(),reportError);
 @override Future<Result<CartsEntity,Failure>> createCart(CartDraft draft) => repositoryGuard(() async => _entity(CartsModel.fromJson(await _remote.createCart({'userId':draft.userId,'date':DateTime.now().toUtc().toIso8601String(),'products':[{'productId':draft.productId,'quantity':draft.quantity}]}))),reportError);
 @override Future<Result<void,Failure>> deleteCart(int id) => repositoryGuard<void>(() => _remote.deleteCart(id),reportError);'''
 elif f=='users':
  methods='''UsersEntity _entity(UsersModel m) => UsersEntity(id:m.id,username:m.username,email:m.email,firstName:m.name.firstname,lastName:m.name.lastname,phone:m.phone,city:m.address.city,street:m.address.street,zipcode:m.address.zipcode);
 @override Future<Result<List<UsersEntity>,Failure>> fetch() => repositoryGuard(() async => (await _remote.fetch()).map((j)=>_entity(UsersModel.fromJson(j))).toList(),reportError);
 @override Future<Result<UsersEntity,Failure>> getUserProfile(int id) => repositoryGuard(() async => _entity(UsersModel.fromJson(await _remote.getUserProfile(id))),reportError);'''
 else:
  methods='''final SessionStore _session;
 @override Future<Result<AuthEntity,Failure>> fetch() async => Success(_session.value ?? const AuthEntity(token:'',username:'',userId:0));
 @override Future<Result<AuthEntity,Failure>> signIn({required String username,required String password}) => repositoryGuard(() async {
  final model = AuthModel.fromJson(await _remote.signIn(username,password));
  final users = await _remote.users();
  final user = users.where((u)=>u['username']==username).firstOrNull;
  if (model.token.isEmpty || user == null || user['id'] is! int) throw const FormatException('Invalid session response.');
  final entity = AuthEntity(token:model.token,username:username,userId:user['id'] as int);
  _session.signIn(entity); return entity;
 },reportError);
 @override Future<Result<void,Failure>> signOut() async { _session.signOut(); return const Success<void,Failure>(null); }'''
 ctor=f'{t}RepositoryImpl(this._remote, '+('this._session, ' if f=='auth' else '')+'{this.reportError = reportUnexpectedError});'
 put(f'lib/features/{f}/data/repositories/{f}_repository_impl.dart',f"""import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/error_reporter.dart';
import 'package:cleany_store/core/errors/repository_guard.dart';
import '../../domain/entities/{f}_entity.dart';
import '../../domain/repositories/{f}_repository.dart';
import '../datasources/{f}_remote_data_source.dart';
import '../models/{f}_model.dart';
{extra}
/// Owns JSON -> DTO -> Entity conversion and the single Failure boundary.
class {t}RepositoryImpl implements {t}Repository {{
 const {ctor}
 final {t}RemoteDataSource _remote;
 final ErrorReporter reportError;
 {methods}
}}""")
# GetCarts coordinates two Domain contracts; Data layers do not import each other.
put('lib/features/carts/domain/usecases/cart_enrichment.dart', '''import '../entities/carts_entity.dart';
import '../../../products/domain/entities/products_entity.dart';
/// Joins business entities; transport DTOs never cross this boundary.
CartsEntity enrichCart(CartsEntity cart, List<ProductsEntity> products) {
 final index = {for(final product in products) product.id:product};
 return cart.copyWith(products: cart.products.map((line) {
  final p = index[line.productId];
  return line.copyWith(title:p?.title ?? 'Product #${line.productId}',image:p?.image ?? '',unitPrice:p?.price ?? 0);
 }).toList());
}''')
for f in ['products','users']:
 t=f.title();put(f'lib/features/{f}/domain/usecases/get_{f}.dart',f"""import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import '../entities/{f}_entity.dart';
import '../repositories/{f}_repository.dart';
class Get{t} {{ const Get{t}(this._repository); final {t}Repository _repository;
 Future<Result<List<{t}Entity>,Failure>> call() => _repository.fetch(); }}""")
put('lib/features/carts/domain/usecases/get_carts.dart', '''import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import '../entities/carts_entity.dart';
import '../repositories/carts_repository.dart';
import '../../../products/domain/repositories/products_repository.dart';
import 'cart_enrichment.dart';
class GetCarts {
 const GetCarts(this._repository,this._products);
 final CartsRepository _repository; final ProductsRepository _products;
 Future<Result<List<CartsEntity>,Failure>> call() async {
  final carts = await _repository.fetch();
  if(carts.isError()) return Error(carts.tryGetError()!);
  final products = await _products.fetch();
  if(products.isError()) return Error(products.tryGetError()!);
  return Success(carts.tryGetSuccess()!.map((c)=>enrichCart(c,products.tryGetSuccess()!)).toList());
 }
}''')
put('lib/features/carts/domain/usecases/create_cart.dart', '''import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import '../entities/carts_entity.dart';
import '../entities/cart_draft.dart';
import '../repositories/carts_repository.dart';
import '../../../products/domain/repositories/products_repository.dart';
import 'cart_enrichment.dart';
/// Validate the business request, create a simulated API cart, then enrich it.
class CreateCart {
 const CreateCart(this._repository,this._products);
 final CartsRepository _repository; final ProductsRepository _products;
 Future<Result<CartsEntity,Failure>> call(CartDraft draft) async {
  if(draft.quantity<1 || draft.quantity>99 || draft.productId<1 || draft.userId<1) return const Error(ValidationFailure());
  final products = await _products.fetch();
  if(products.isError()) return Error(products.tryGetError()!);
  final cart = await _repository.createCart(draft);
  return cart.when((c)=>Success(enrichCart(c,products.tryGetSuccess()!)),(f)=>Error(f));
 }
}''')
put('lib/features/carts/domain/usecases/delete_cart.dart', '''import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import '../repositories/carts_repository.dart';
/// Fake Store simulates deletion; a later refresh returns the server dataset.
class DeleteCart { const DeleteCart(this._repository); final CartsRepository _repository;
 Future<Result<void,Failure>> call(int id) => id>0 ? _repository.deleteCart(id) : Future.value(const Error(ValidationFailure())); }''')
put('lib/features/users/domain/usecases/get_user_profile.dart', '''import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import '../entities/users_entity.dart';
import '../repositories/users_repository.dart';
class GetUserProfile { const GetUserProfile(this._repository); final UsersRepository _repository;
 Future<Result<UsersEntity,Failure>> call(int id) => id>0 ? _repository.getUserProfile(id) : Future.value(const Error(ValidationFailure())); }''')
put('lib/features/auth/domain/usecases/sign_in.dart', '''import 'package:multiple_result/multiple_result.dart';
import 'package:cleany_store/core/errors/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';
class SignIn { const SignIn(this._repository); final AuthRepository _repository;
 Future<Result<AuthEntity,Failure>> call({required String username,required String password}) {
  if(username.trim().isEmpty || password.isEmpty) return Future.value(const Error(ValidationFailure()));
  return _repository.signIn(username:username.trim(),password:password);
 }
}''')
# Session state is reusable Core data, independent of any feature.
put('lib/core/storage/session_store.dart', '''import 'package:flutter/foundation.dart';
/// In-memory demo session. Never retains passwords or writes tokens to disk.
class SessionData {
 const SessionData({required this.accessToken,required this.username,required this.userId});
 final String accessToken; final String username; final int userId;
 @override String toString() => 'SessionData(userId: $userId)';
}
class SessionStore extends ValueNotifier<SessionData?> {
 SessionStore():super(null);
 void signIn(SessionData session) { value=session; }
 void signOut() { value=null; }
}''')
p=OUT/'lib/features/auth/data/repositories/auth_repository_impl.dart';s=p.read_text().replace("Success(_session.value ?? const AuthEntity(token:'',username:'',userId:0))", "Success(AuthEntity(token:_session.value?.accessToken ?? '',username:_session.value?.username ?? '',userId:_session.value?.userId ?? 0))").replace('_session.signIn(entity)', '_session.signIn(SessionData(accessToken:entity.token,username:entity.username,userId:entity.userId))');p.write_text(s)
put('lib/core/errors/error_reporter.dart', '''import 'dart:developer' as developer;
typedef ErrorReporter = void Function(Object error, StackTrace stackTrace);
/// Logs diagnostics without serializing request bodies, credentials or tokens.
void reportUnexpectedError(Object error, StackTrace stackTrace) {
 developer.log('Unexpected ${error.runtimeType}',name:'cleany_store',stackTrace:stackTrace,level:1000);
}''')
# Immutable presentation unions keep the action fields generated by Cleany.
def state_file(f,mode,statuses,collection=False,extra=''):
 t=f.title();fields=', '.join(f'@Default(UseCaseState<{kind}>.initial()) UseCaseState<{kind}> {name}' for name,kind in statuses)
 if extra:fields+=', '+extra
 entity_type=f'List<{t}Entity>' if collection else t+'Entity';value_name=f if collection else 'entity'
 put(f'lib/features/{f}/presentation/{mode}/{f}_state.dart',f"""import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{f}_entity.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
part '{f}_state.freezed.dart';
@freezed
sealed class {t}State with _${t}State {{
 const factory {t}State.initial({{{fields}}})={t}Initial;
 const factory {t}State.loading({{{fields}}})={t}Loading;
 const factory {t}State.success({entity_type} {value_name},{{{fields}}})={t}Success;
 const factory {t}State.failure(Failure failure,{{{fields}}})={t}Failure;
}}""")
state_file('products','cubit',[('getFeaturedProductStatus','ProductsEntity')],True, "@Default('') String query, String? category, @Default(false) bool priceAscending")
state_file('carts','bloc',[('createCartStatus','CartsEntity'),('deleteCartStatus','void')],True, '@Default(<int>[]) List<int> deletedIds')
state_file('users','cubit',[('getUserProfileStatus','UsersEntity')],True, "@Default('') String query")
state_file('auth','cubit',[('signInStatus','AuthEntity'),('signOutStatus','void')])
put('lib/features/products/presentation/cubit/products_cubit.dart', '''import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_featured_product.dart';
import '../../domain/entities/products_entity.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'products_state.dart';
/// Owns catalog loading, local presentation filters and the generated spotlight action.
class ProductsCubit extends Cubit<ProductsState> {
 ProductsCubit(this._getProducts,{required this.getFeaturedProductUseCase}):super(const ProductsState.initial());
 final GetProducts _getProducts; final GetFeaturedProduct getFeaturedProductUseCase;
 Future<void> load() async {
  if(isClosed || state is ProductsLoading) return;
  emit(ProductsState.loading(query:state.query,category:state.category,priceAscending:state.priceAscending,getFeaturedProductStatus:state.getFeaturedProductStatus));
  final result=await _getProducts(); if(isClosed)return;
  result.when((items)=>emit(ProductsState.success(items,query:state.query,category:state.category,priceAscending:state.priceAscending,getFeaturedProductStatus:state.getFeaturedProductStatus)),
   (failure)=>emit(ProductsState.failure(failure,query:state.query,category:state.category,priceAscending:state.priceAscending,getFeaturedProductStatus:state.getFeaturedProductStatus)));
 }
 void search(String query) { if(!isClosed) emit(state.copyWith(query:query)); }
 void selectCategory(String? category) { if(!isClosed) emit(state.copyWith(category:category)); }
 void toggleSort() { if(!isClosed) emit(state.copyWith(priceAscending:!state.priceAscending)); }
 List<ProductsEntity> get visibleProducts {
  final current=state; if(current is! ProductsSuccess)return [];
  final result=current.products.where((p)=>(state.category==null || p.category==state.category) && p.title.toLowerCase().contains(state.query.toLowerCase())).toList();
  if(state.priceAscending) result.sort((a,b)=>a.price.compareTo(b.price));
  return result;
 }
 Future<void> getFeaturedProduct() async {
  if(isClosed || state.getFeaturedProductStatus is UseCaseLoading<ProductsEntity>)return;
  emit(state.copyWith(getFeaturedProductStatus:const UseCaseState.loading()));
  final result=await getFeaturedProductUseCase(); if(isClosed)return;
  result.when((p)=>emit(state.copyWith(getFeaturedProductStatus:UseCaseState.success(p))),
   (f)=>emit(state.copyWith(getFeaturedProductStatus:UseCaseState.failure(f))));
 }
}''')
put('lib/features/users/presentation/cubit/users_cubit.dart', '''import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/entities/users_entity.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'users_state.dart';
class UsersCubit extends Cubit<UsersState> {
 UsersCubit(this._getUsers,{required this.getUserProfileUseCase}):super(const UsersState.initial());
 final GetUsers _getUsers; final GetUserProfile getUserProfileUseCase;
 int _request=0;
 Future<void> load() async {
  if(isClosed || state is UsersLoading)return;
  emit(UsersState.loading(query:state.query,getUserProfileStatus:state.getUserProfileStatus));
  final result=await _getUsers();if(isClosed)return;
  result.when((items)=>emit(UsersState.success(items,query:state.query,getUserProfileStatus:state.getUserProfileStatus)),
   (f)=>emit(UsersState.failure(f,query:state.query,getUserProfileStatus:state.getUserProfileStatus)));
 }
 void search(String query){if(!isClosed)emit(state.copyWith(query:query));}
 List<UsersEntity> get visibleUsers {final current=state;return current is UsersSuccess?current.users.where((u)=>'${u.firstName} ${u.lastName} ${u.username}'.toLowerCase().contains(state.query.toLowerCase())).toList():[];}
 Future<void> getUserProfile(int id) async {
  if(isClosed)return; final request=++_request;
  emit(state.copyWith(getUserProfileStatus:const UseCaseState.loading()));
  final result=await getUserProfileUseCase(id);if(isClosed || request!=_request)return;
  result.when((u)=>emit(state.copyWith(getUserProfileStatus:UseCaseState.success(u))),
   (f)=>emit(state.copyWith(getUserProfileStatus:UseCaseState.failure(f))));
 }
}''')
put('lib/features/carts/presentation/bloc/carts_event.dart', '''import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cart_draft.dart';
part 'carts_event.freezed.dart';
@freezed
sealed class CartsEvent with _$CartsEvent {
 const factory CartsEvent.requested()=CartsRequested;
 const factory CartsEvent.createCartRequested(CartDraft draft)=CartsCreateCartRequested;
 const factory CartsEvent.deleteCartRequested(int id)=CartsDeleteCartRequested;
}''')
put('lib/features/carts/presentation/bloc/carts_bloc.dart', '''import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_carts.dart';
import '../../domain/usecases/create_cart.dart';
import '../../domain/usecases/delete_cart.dart';
import '../../domain/entities/carts_entity.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'carts_state.dart';
import 'carts_event.dart';
/// Generated operation wiring extended with typed requests for the real API.
class CartsBloc extends Bloc<CartsEvent,CartsState> {
 CartsBloc(this._getCarts,{required this.createCartUseCase,required this.deleteCartUseCase}):super(const CartsState.initial()) {
  on<CartsRequested>(_load);on<CartsCreateCartRequested>(_create);on<CartsDeleteCartRequested>(_delete);
 }
 final GetCarts _getCarts; final CreateCart createCartUseCase; final DeleteCart deleteCartUseCase;
 Future<void> reload() async {
  final done=stream.firstWhere((s)=>s is CartsSuccess || s is CartsFailure).timeout(const Duration(seconds:40));
  add(const CartsEvent.requested());await done;
 }
 Future<void> _load(CartsRequested event,Emitter<CartsState> emit) async {
  if(state is CartsLoading)return;
  emit(CartsState.loading(createCartStatus:state.createCartStatus,deleteCartStatus:state.deleteCartStatus));
  final result=await _getCarts();if(emit.isDone)return;
  result.when((items)=>emit(CartsState.success(items,createCartStatus:state.createCartStatus,deleteCartStatus:state.deleteCartStatus,deletedIds:state.deletedIds)),
   (f)=>emit(CartsState.failure(f,createCartStatus:state.createCartStatus,deleteCartStatus:state.deleteCartStatus,deletedIds:state.deletedIds)));
 }
 Future<void> _create(CartsCreateCartRequested event,Emitter<CartsState> emit) async {
  if(state.createCartStatus is UseCaseLoading<CartsEntity>)return;
  emit(state.copyWith(createCartStatus:const UseCaseState.loading()));
  final result=await createCartUseCase(event.draft);if(emit.isDone)return;
  result.when((cart)=>emit(state.copyWith(createCartStatus:UseCaseState.success(cart))),
   (f)=>emit(state.copyWith(createCartStatus:UseCaseState.failure(f))));
 }
 Future<void> _delete(CartsDeleteCartRequested event,Emitter<CartsState> emit) async {
  if(state.deleteCartStatus is UseCaseLoading<void>)return;
  emit(state.copyWith(deleteCartStatus:const UseCaseState.loading()));
  final result=await deleteCartUseCase(event.id);if(emit.isDone)return;
  result.when((_)=>emit(state.copyWith(deleteCartStatus:const UseCaseState<void>.success(null),deletedIds:[...state.deletedIds,event.id])),
   (f)=>emit(state.copyWith(deleteCartStatus:UseCaseState.failure(f))));
 }
}''')
put('lib/features/auth/presentation/cubit/auth_cubit.dart', '''import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_auth.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/entities/auth_entity.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'auth_state.dart';
class AuthCubit extends Cubit<AuthState> {
 AuthCubit(this._getAuth,{required this.signInUseCase,required this.signOutUseCase}):super(const AuthState.initial());
 final GetAuth _getAuth; final SignIn signInUseCase; final SignOut signOutUseCase;
 Future<void> load() async {final result=await _getAuth();if(isClosed)return;result.when((s)=>emit(AuthState.success(s)),(f)=>emit(AuthState.failure(f)));}
 Future<void> signIn({required String username,required String password}) async {
  if(isClosed || state.signInStatus is UseCaseLoading<AuthEntity>)return;
  emit(state.copyWith(signInStatus:const UseCaseState.loading()));
  final result=await signInUseCase(username:username,password:password);if(isClosed)return;
  result.when((session)=>emit(AuthState.success(session,signInStatus:UseCaseState.success(session))),
   (f)=>emit(state.copyWith(signInStatus:UseCaseState.failure(f))));
 }
 Future<void> signOut() async {
  if(isClosed || state.signOutStatus is UseCaseLoading<void>)return;
  emit(state.copyWith(signOutStatus:const UseCaseState.loading()));
  final result=await signOutUseCase();if(isClosed)return;
  result.when((_)=>emit(const AuthState.initial(signOutStatus:UseCaseState<void>.success(null))),
   (f)=>emit(state.copyWith(signOutStatus:UseCaseState.failure(f))));
 }
}''')
# Official Flutter ARB localization, including Arabic/RTL and presentation errors.
strings={
'appTitle':('Cleany Store','متجر كليني'),'catalog':('Discover','اكتشف'),'carts':('Carts','السلال'),'users':('Community','المستخدمون'),'account':('Account','حسابي'),
'brand':('cleany / store','cleany / store'),'tagline':('A little everyday discovery.','اكتشافات صغيرة، كل يوم.'),'catalogTitle':('Find your next favorite.','اكتشف ما يعجبك.'),
'catalogSubtitle':('Thoughtful picks. Real API. Built with Cleany.','منتجات مختارة، وواجهة حقيقية بُنيت مع كليني.'),'searchProducts':('Search products','ابحث عن منتج'),
'all':('All','الكل'),'priceSort':('Price: low to high','السعر: من الأقل'),'featuredSort':('Featured order','الترتيب الأصلي'),'spotlight':('THE DAILY FIND','اختيار اليوم'),
'viewProduct':('Take a closer look','اكتشف المنتج'),'addToCart':('Create demo cart','إنشاء سلة تجريبية'),'productDetails':('Product details','تفاصيل المنتج'),
'quantity':('Quantity','الكمية'),'reviews':('reviews','تقييم'),'retry':('Try again','حاول مجددًا'),'noResults':('Nothing here yet','لا توجد نتائج'),
'noProductsHint':('Try another search or category.','جرّب بحثًا أو تصنيفًا آخر.'),'networkError':('Could not reach the store. Check your connection.','تعذّر الاتصال بالمتجر. تحقق من اتصالك.'),
'genericError':('Something went wrong. Please try again.','حدث خطأ. حاول مرة أخرى.'),'invalidCredentials':('Username or password is incorrect.','اسم المستخدم أو كلمة المرور غير صحيحة.'),
'invalidData':('The server returned an unexpected response.','أعاد الخادم استجابة غير متوقعة.'),'serverError':('The demo service is temporarily unavailable.','الخدمة التجريبية غير متاحة حاليًا.'),
'demo':('LIVE API DEMO','تجربة API مباشرة'),'demoNotice':('Fake Store simulates writes. New carts and deletions are not persisted on its server.','يحاكي Fake Store عمليات التعديل؛ السلال الجديدة والحذف لا تُحفظ على خادمه.'),
'cartsTitle':('A peek inside the bag.','نظرة داخل السلة.'),'cartsSubtitle':('Public demo carts, with product details joined in Domain.','سلال تجريبية عامة، تُربط بيانات منتجاتها في Domain.'),
'newCart':('Your new demo cart','سلتك التجريبية الجديدة'),'creatingCart':('Creating your demo cart…','جارٍ إنشاء سلتك التجريبية…'),'cartCreated':('Cart created successfully','تم إنشاء السلة بنجاح'),
'cartLabel':('Cart','السلة'),'userLabel':('User','المستخدم'),'items':('items','عناصر'),'total':('Total','الإجمالي'),'simulateDelete':('Simulate delete','محاكاة الحذف'),
'cartDeleted':('Removed from this view. The API dataset resets on refresh.','أُزيلت من العرض الحالي. بيانات API تعود بعد التحديث.'),'refresh':('Refresh','تحديث'),
'usersTitle':('Meet the demo community.','تعرّف إلى مجتمع التجربة.'),'usersSubtitle':('Public sample profiles. No passwords are displayed.','حسابات عامة للاختبار. لا نعرض كلمات المرور.'),
'searchUsers':('Search people','ابحث عن مستخدم'),'profile':('Profile','الملف الشخصي'),'email':('Email','البريد الإلكتروني'),'phone':('Phone','الهاتف'),'address':('Address','العنوان'),
'signInTitle':('Welcome to your store.','أهلًا بك في متجرك.'),'signInSubtitle':('Sign in with a public Fake Store demo account.','سجّل الدخول بحساب Fake Store التجريبي العام.'),
'username':('Username','اسم المستخدم'),'password':('Password','كلمة المرور'),'signIn':('Sign in','تسجيل الدخول'),'signOut':('Sign out','تسجيل الخروج'),
'useDemoAccount':('Use public demo account','استخدام الحساب التجريبي العام'),'requiredField':('This field is required.','هذا الحقل مطلوب.'),
'signedIn':('You’re signed in','تم تسجيل الدخول'),'sessionMemory':('JWT received. Your session is held in memory and clears when the app closes.','تم استلام JWT. الجلسة في الذاكرة فقط وتُمسح عند إغلاق التطبيق.'),
'guest':('Guest · demo user #1','زائر · المستخدم التجريبي 1'),'language':('العربية','English'),'madeWith':('Scaffolded with local CLEANY 2.0.2','وُلّدت الهيكلة باستخدام CLEANY 2.0.2 المحلية'),
'close':('Close','إغلاق'),'browseProducts':('Browse products','تصفح المنتجات'),'emptyCarts':('No carts to show','لا توجد سلال للعرض'),'signedOut':('Signed out','تم تسجيل الخروج')}
for locale,index in [('en',0),('ar',1)]:
 put(f'assets/translations/app_{locale}.arb',json.dumps({'@@locale':locale,**{key:value[index] for key,value in strings.items()}},ensure_ascii=False,indent=2))
put('lib/core/localization/store_localization.dart', '''import 'package:flutter/widgets.dart';
import '../errors/failure.dart';
import 'generated/app_localizations.dart';
export 'generated/app_localizations.dart';
extension StoreLocalization on BuildContext {
 AppLocalizations get l10n => AppLocalizations.of(this);
 String failureText(Failure failure) => switch(failure) {
  NetworkFailure()=>l10n.networkError, UnauthorizedFailure()=>l10n.invalidCredentials,
  ValidationFailure()=>l10n.invalidData, ServerFailure()=>l10n.serverError,
  _=>l10n.genericError,
 };
}''')
put('lib/core/theme/app_theme.dart', '''import 'package:flutter/material.dart';
class AppTheme {
 AppTheme._();
 static const ink=Color(0xFF163F35); static const accent=Color(0xFFF0B68B); static const background=Color(0xFFF7F7F2);
 static ThemeData get light => ThemeData(useMaterial3:true,
  colorScheme:ColorScheme.fromSeed(seedColor:ink,surface:background).copyWith(primary:ink,secondary:const Color(0xFFB5633E)),
  scaffoldBackgroundColor:background,
  appBarTheme:const AppBarTheme(backgroundColor:background,foregroundColor:ink,elevation:0,scrolledUnderElevation:0,centerTitle:false),
  inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:16),
   border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:ink))),
  filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(minimumSize:const Size(48,52),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)))),
  cardTheme:CardThemeData(color:Colors.white,elevation:0,margin:EdgeInsets.zero,clipBehavior:Clip.antiAlias,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22))),
  navigationBarTheme:NavigationBarThemeData(backgroundColor:Colors.white,indicatorColor:ink.withValues(alpha:.1),height:76),
  textTheme:const TextTheme(headlineLarge:TextStyle(fontSize:32,fontWeight:FontWeight.w800,letterSpacing:-1.2,color:ink),titleLarge:TextStyle(fontSize:22,fontWeight:FontWeight.w700,color:ink),titleMedium:TextStyle(fontSize:16,fontWeight:FontWeight.w700,color:ink),bodyMedium:TextStyle(fontSize:14,height:1.45,color:Color(0xFF52625D)))),
 );
}''')
