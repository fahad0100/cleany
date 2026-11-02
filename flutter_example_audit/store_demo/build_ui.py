from build_app import put,OUT
put('lib/components/status_panel/status_panel_widget.dart', '''import 'package:flutter/material.dart';
/// Reusable empty/error surface generated as a stateless Cleany component.
class StatusPanelWidget extends StatelessWidget {
 const StatusPanelWidget({super.key,required this.title,this.description,this.icon=Icons.inbox_outlined,this.onRetry,this.retryLabel});
 final String title; final String? description; final IconData icon; final VoidCallback? onRetry; final String? retryLabel;
 @override Widget build(BuildContext context) => Padding(padding:const EdgeInsets.symmetric(horizontal:28,vertical:40),child:Column(mainAxisSize:MainAxisSize.min,children:[
  CircleAvatar(radius:32,backgroundColor:Theme.of(context).colorScheme.primary.withValues(alpha:.08),child:Icon(icon,size:30,color:Theme.of(context).colorScheme.primary)),
  const SizedBox(height:18),Text(title,style:Theme.of(context).textTheme.titleLarge,textAlign:TextAlign.center),
  if(description!=null)...[const SizedBox(height:8),Text(description!,textAlign:TextAlign.center)],
  if(onRetry!=null)...[const SizedBox(height:20),FilledButton.icon(onPressed:onRetry,icon:const Icon(Icons.refresh),label:Text(retryLabel??'Retry'))],
 ]));
}''')
put('lib/components/quantity_stepper/cubit/quantity_stepper_cubit.dart', '''import 'package:flutter_bloc/flutter_bloc.dart';
import 'quantity_stepper_state.dart';
/// Local quantity state is owned/disposed by the component's BlocProvider.
class QuantityStepperCubit extends Cubit<QuantityStepperState> {
 QuantityStepperCubit():super(const QuantityStepperState.updated(1));
 void update(int value){if(!isClosed)emit(QuantityStepperState.updated(value.clamp(1,99).toInt()));}
}''')
put('lib/components/quantity_stepper/quantity_stepper_widget.dart', '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/quantity_stepper_cubit.dart';
import 'cubit/quantity_stepper_state.dart';
/// Flat component widget; state imports are siblings, not ../widgets paths.
class QuantityStepperWidget extends StatelessWidget {
 const QuantityStepperWidget({super.key,this.onChanged});
 final ValueChanged<int>? onChanged;
 @override Widget build(BuildContext context) => BlocConsumer<QuantityStepperCubit,QuantityStepperState>(
  listener:(_,state){if(state case QuantityStepperUpdated(:final value))onChanged?.call(value);},
  builder:(context,state){final value=switch(state){QuantityStepperInitial()=>1,QuantityStepperUpdated(:final value)=>value};
   return Container(decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary.withValues(alpha:.06),borderRadius:BorderRadius.circular(16)),child:Row(mainAxisSize:MainAxisSize.min,children:[
    IconButton(key:const Key('quantity-minus'),onPressed:value>1?()=>context.read<QuantityStepperCubit>().update(value-1):null,icon:const Icon(Icons.remove,size:20)),
    Text('$value',key:const Key('quantity-value'),style:Theme.of(context).textTheme.titleMedium),
    IconButton(key:const Key('quantity-plus'),onPressed:()=>context.read<QuantityStepperCubit>().update(value+1),icon:const Icon(Icons.add,size:20)),
   ]));
  });
}''')
put('lib/components/product_card/product_card_widget.dart', '''import 'package:flutter/material.dart';
import 'package:cleany_store/features/products/domain/entities/products_entity.dart';
/// Domain-only input makes this generated stateless component reusable and testable.
class ProductCardWidget extends StatelessWidget {
 const ProductCardWidget({super.key,required this.product,required this.onTap,required this.onAdd});
 final ProductsEntity product;final VoidCallback onTap;final VoidCallback onAdd;
 @override Widget build(BuildContext context)=>Card(child:InkWell(key:Key('product-${product.id}'),onTap:onTap,child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Expanded(child:Center(child:Hero(tag:'product-${product.id}',child:Image.network(product.image,fit:BoxFit.contain,cacheWidth:420,
   errorBuilder:(_,_,_)=>const Icon(Icons.image_not_supported_outlined,size:38,color:Colors.grey),loadingBuilder:(_,child,progress)=>progress==null?child:const Center(child:SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2))))))),
  const SizedBox(height:12),Text(product.category.toUpperCase(),maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,letterSpacing:.8,color:Color(0xFF6D7C75),fontWeight:FontWeight.w600)),
  const SizedBox(height:5),Text(product.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:13,height:1.3,fontWeight:FontWeight.w600,color:Color(0xFF163F35))),
  const SizedBox(height:5),Row(children:[const Icon(Icons.star_rounded,color:Color(0xFFD5933C),size:14),const SizedBox(width:3),Text('${product.rating.toStringAsFixed(1)} (${product.reviewCount})',style:const TextStyle(fontSize:10,color:Color(0xFF6D7C75)))]),
  Row(children:[Expanded(child:Directionality(textDirection:TextDirection.ltr,child:Text('\\$${product.price.toStringAsFixed(2)}',style:Theme.of(context).textTheme.titleMedium))),
   IconButton(key:Key('add-${product.id}'),tooltip:'Add to demo cart',onPressed:onAdd,style:IconButton.styleFrom(backgroundColor:const Color(0xFF163F35),foregroundColor:Colors.white,minimumSize:const Size(32,32)),icon:const Icon(Icons.add,size:18))]),
 ])))));
}''')
put('lib/app/store_shell.dart', '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/storage/session_store.dart';
import 'config/store_preferences.dart';
/// Navigation and language preference belong to App, outside business features.
class StoreShell extends StatelessWidget {
 const StoreShell({super.key,required this.child,required this.location,required this.preferences,required this.session});
 final Widget child;final String location;final StorePreferences preferences;final SessionStore session;
 @override Widget build(BuildContext context) {
  final l=context.l10n;final paths=['/products','/carts','/users','/auth'];final index=paths.indexOf(location);
  return Scaffold(appBar:AppBar(title:Row(children:[Container(width:34,height:34,decoration:BoxDecoration(color:const Color(0xFF163F35),borderRadius:BorderRadius.circular(11)),child:const Icon(Icons.shopping_bag_outlined,color:Colors.white,size:20)),const SizedBox(width:10),const Text('cleany / store',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800,letterSpacing:-.7))]),
   actions:[TextButton(key:const Key('language-toggle'),onPressed:preferences.toggleLanguage,child:Text(l.language)),const SizedBox(width:8)]),
   body:child,bottomNavigationBar:NavigationBar(selectedIndex:index<0?0:index,onDestinationSelected:(i)=>context.go(paths[i]),destinations:[
    NavigationDestination(icon:const Icon(Icons.grid_view_outlined),selectedIcon:const Icon(Icons.grid_view_rounded),label:l.catalog),
    NavigationDestination(icon:const Icon(Icons.shopping_bag_outlined),selectedIcon:const Icon(Icons.shopping_bag),label:l.carts),
    NavigationDestination(icon:const Icon(Icons.people_outline),selectedIcon:const Icon(Icons.people),label:l.users),
    NavigationDestination(icon:ValueListenableBuilder<SessionData?>(valueListenable:session,builder:(_,s,_)=>Icon(s==null?Icons.person_outline:Icons.verified_user_outlined)),selectedIcon:const Icon(Icons.person),label:l.account),
   ]));
 }
}''')
put('lib/features/products/presentation/pages/products_page.dart', '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/components/product_card/product_card_widget.dart';
import 'package:cleany_store/components/status_panel/status_panel_widget.dart';
import 'package:cleany_store/components/quantity_stepper/cubit/quantity_stepper_cubit.dart';
import 'package:cleany_store/components/quantity_stepper/quantity_stepper_widget.dart';
import 'package:cleany_store/features/carts/domain/entities/cart_draft.dart';
import '../../domain/entities/products_entity.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';

class ProductsPage extends StatefulWidget {
 const ProductsPage({super.key,required this.createQuantityController});
 final QuantityStepperCubit Function() createQuantityController;
 @override State<ProductsPage> createState()=>_ProductsPageState();
}
class _ProductsPageState extends State<ProductsPage> {
 final _search=TextEditingController();
 @override void dispose(){_search.dispose();super.dispose();}
 void _add(ProductsEntity product,int quantity)=>context.go('/carts',extra:CartDraft(productId:product.id,quantity:quantity));
 void _details(ProductsEntity product){
  var quantity=1;
  showModalBottomSheet<void>(context:context,isScrollControlled:true,showDragHandle:true,useSafeArea:true,builder:(sheetContext)=>BlocProvider(
   create:(_)=>widget.createQuantityController(),child:Padding(padding:const EdgeInsets.fromLTRB(24,4,24,24),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Center(child:Image.network(product.image,height:210,fit:BoxFit.contain,errorBuilder:(_,_,_)=>const Icon(Icons.image_outlined,size:80))),const SizedBox(height:22),
    Text(product.category.toUpperCase(),style:const TextStyle(letterSpacing:1,color:Colors.grey,fontSize:11)),const SizedBox(height:8),Text(product.title,style:Theme.of(context).textTheme.titleLarge),
    const SizedBox(height:12),Directionality(textDirection:TextDirection.ltr,child:Text('\\$${product.price.toStringAsFixed(2)}',style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:Color(0xFF163F35)))),
    const SizedBox(height:12),Text(product.description),const SizedBox(height:22),Row(children:[Expanded(child:Text(context.l10n.quantity,style:Theme.of(context).textTheme.titleMedium)),QuantityStepperWidget(onChanged:(value)=>quantity=value)]),
    const SizedBox(height:22),SizedBox(width:double.infinity,child:FilledButton.icon(key:const Key('detail-add-to-cart'),onPressed:(){Navigator.of(sheetContext).pop();_add(product,quantity);},icon:const Icon(Icons.shopping_bag_outlined),label:Text(context.l10n.addToCart))),
   ])))));
 }
 @override Widget build(BuildContext context)=>BlocBuilder<ProductsCubit,ProductsState>(builder:(context,state){
  final l=context.l10n;final cubit=context.read<ProductsCubit>();
  final items=cubit.visibleProducts;
  final categories=state is ProductsSuccess?state.products.map((p)=>p.category).toSet().toList():<String>[];
  return RefreshIndicator(onRefresh:cubit.load,child:CustomScrollView(key:const PageStorageKey('catalog-scroll'),physics:const AlwaysScrollableScrollPhysics(),slivers:[
   SliverPadding(padding:const EdgeInsets.fromLTRB(22,14,22,0),sliver:SliverToBoxAdapter(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Container(width:6,height:6,decoration:const BoxDecoration(color:Color(0xFF378E65),shape:BoxShape.circle)),const SizedBox(width:7),Text(l.demo,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700,letterSpacing:1.3,color:Color(0xFF5D786B)))]),
    const SizedBox(height:14),Text(l.catalogTitle,style:Theme.of(context).textTheme.headlineLarge),const SizedBox(height:8),Text(l.catalogSubtitle),const SizedBox(height:20),
    TextField(key:const Key('product-search'),controller:_search,onChanged:cubit.search,decoration:InputDecoration(hintText:l.searchProducts,prefixIcon:const Icon(Icons.search,size:22),suffixIcon:IconButton(tooltip:l.refresh,onPressed:(){_search.clear();cubit.search('');},icon:const Icon(Icons.close,size:18)))),
    const SizedBox(height:16),
    if(state.getFeaturedProductStatus case UseCaseSuccess<ProductsEntity>(:final value))...[
     InkWell(onTap:()=>_details(value),borderRadius:BorderRadius.circular(22),child:Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFFDFEAE1),borderRadius:BorderRadius.circular(22)),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(l.spotlight,style:const TextStyle(fontSize:9,letterSpacing:1.5,fontWeight:FontWeight.w800,color:Color(0xFF397361))),const SizedBox(height:9),Text(value.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w700,color:Color(0xFF163F35))),const SizedBox(height:9),Text(l.viewProduct,style:const TextStyle(fontSize:11,decoration:TextDecoration.underline,color:Color(0xFF397361)))])),const SizedBox(width:18),ClipRRect(borderRadius:BorderRadius.circular(14),child:Container(color:Colors.white,padding:const EdgeInsets.all(10),child:Image.network(value.image,width:82,height:92,fit:BoxFit.contain,errorBuilder:(_,_,_)=>const Icon(Icons.shopping_bag_outlined,size:60))))]))),const SizedBox(height:18)],
    SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[for(final category in <String?>[null,...categories])Padding(padding:const EdgeInsetsDirectional.only(end:8),child:ChoiceChip(label:Text(category??l.all),selected:state.category==category,onSelected:(_)=>cubit.selectCategory(category),showCheckmark:false,backgroundColor:Colors.white,selectedColor:const Color(0xFF163F35),side:BorderSide.none,labelStyle:TextStyle(fontSize:11,color:state.category==category?Colors.white:const Color(0xFF52625D))))])),
    const SizedBox(height:12),Row(children:[Expanded(child:Text('${items.length} ${l.items}',style:const TextStyle(fontSize:12,color:Colors.grey))),TextButton.icon(onPressed:cubit.toggleSort,icon:const Icon(Icons.swap_vert,size:16),label:Text(state.priceAscending?l.priceSort:l.featuredSort,style:const TextStyle(fontSize:11)))]),
   ]))),
   if(state is ProductsLoading || state is ProductsInitial)const SliverFillRemaining(hasScrollBody:false,child:Center(child:CircularProgressIndicator()))
   else if(state case ProductsFailure(:final failure))SliverFillRemaining(hasScrollBody:false,child:StatusPanelWidget(title:context.failureText(failure),onRetry:cubit.load,retryLabel:l.retry,icon:Icons.wifi_off_rounded))
   else if(items.isEmpty)SliverFillRemaining(hasScrollBody:false,child:StatusPanelWidget(title:l.noResults,description:l.noProductsHint,onRetry:(){_search.clear();cubit.search('');cubit.selectCategory(null);},retryLabel:l.all))
   else SliverPadding(padding:const EdgeInsets.fromLTRB(18,0,18,24),sliver:SliverLayoutBuilder(builder:(context,constraints)=>SliverGrid(delegate:SliverChildBuilderDelegate((context,index){final product=items[index];return ProductCardWidget(product:product,onTap:()=>_details(product),onAdd:()=>_add(product,1));},childCount:items.length),gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:constraints.crossAxisExtent>800?4:2,mainAxisSpacing:12,crossAxisSpacing:12,mainAxisExtent:292)))),
  ]));
 });
}''')
put('lib/features/carts/presentation/pages/carts_page.dart', '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/components/status_panel/status_panel_widget.dart';
import '../../domain/entities/carts_entity.dart';
import '../bloc/carts_bloc.dart';
import '../bloc/carts_event.dart';
import '../bloc/carts_state.dart';
class CartsPage extends StatelessWidget {
 const CartsPage({super.key});
 @override Widget build(BuildContext context)=>BlocConsumer<CartsBloc,CartsState>(
  listenWhen:(a,b)=>a.deleteCartStatus!=b.deleteCartStatus,
  listener:(context,state){if(state.deleteCartStatus is UseCaseSuccess<void>)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.l10n.cartDeleted)));},
  builder:(context,state){
   final l=context.l10n;final bloc=context.read<CartsBloc>();final carts=state is CartsSuccess?state.carts.where((c)=>!state.deletedIds.contains(c.id)).toList():<CartsEntity>[];
   final created=state.createCartStatus;
   return RefreshIndicator(onRefresh:bloc.reload,child:ListView(padding:const EdgeInsets.fromLTRB(22,16,22,24),physics:const AlwaysScrollableScrollPhysics(),children:[
    Text(l.cartsTitle,style:Theme.of(context).textTheme.headlineLarge),const SizedBox(height:8),Text(l.cartsSubtitle),const SizedBox(height:20),
    Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:const Color(0xFFFFEFDD),borderRadius:BorderRadius.circular(16)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.science_outlined,color:Color(0xFF9E6431),size:22),const SizedBox(width:10),Expanded(child:Text(l.demoNotice,style:const TextStyle(fontSize:12,color:Color(0xFF87603A))))])),
    const SizedBox(height:18),
    if(created is UseCaseLoading<CartsEntity>)Padding(padding:const EdgeInsets.all(20),child:Column(children:[const CircularProgressIndicator(),const SizedBox(height:12),Text(l.creatingCart)])),
    if(created case UseCaseFailure<CartsEntity>(:final failure))StatusPanelWidget(title:context.failureText(failure),retryLabel:l.browseProducts,onRetry:()=>context.go('/products')),
    if(created case UseCaseSuccess<CartsEntity>(:final value))if(!state.deletedIds.contains(value.id))...[
      Text(l.newCart,style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:10),_CartCard(cart:value,canDelete:state.deleteCartStatus is! UseCaseLoading<void>),const SizedBox(height:22)],
    if(state is CartsInitial || state is CartsLoading)const Padding(padding:EdgeInsets.all(50),child:Center(child:CircularProgressIndicator()))
    else if(state case CartsFailure(:final failure))StatusPanelWidget(title:context.failureText(failure),onRetry:()=>bloc.add(const CartsEvent.requested()),retryLabel:l.retry)
    else if(carts.isEmpty)StatusPanelWidget(title:l.emptyCarts,onRetry:()=>context.go('/products'),retryLabel:l.browseProducts)
    else ...[for(final cart in carts)Padding(padding:const EdgeInsets.only(bottom:14),child:_CartCard(cart:cart,canDelete:state.deleteCartStatus is! UseCaseLoading<void>))],
   ]));
  });
}
class _CartCard extends StatelessWidget {
 const _CartCard({required this.cart,required this.canDelete});
 final CartsEntity cart;final bool canDelete;
 @override Widget build(BuildContext context){
  final l=context.l10n;final total=cart.products.fold<double>(0,(sum,p)=>sum+p.quantity*p.unitPrice);
  return Card(key:Key('cart-${cart.id}'),child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Row(children:[Expanded(child:Text('${l.cartLabel} #${cart.id}',style:Theme.of(context).textTheme.titleMedium)),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),decoration:BoxDecoration(color:const Color(0xFFEEF3ED),borderRadius:BorderRadius.circular(10)),child:Text('${l.userLabel} #${cart.userId}',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700)))]),
   const SizedBox(height:5),Text(MaterialLocalizations.of(context).formatShortDate(cart.date),style:const TextStyle(fontSize:11,color:Colors.grey)),const SizedBox(height:14),
   for(final line in cart.products)Padding(padding:const EdgeInsets.only(bottom:12),child:Row(children:[Container(width:46,height:50,padding:const EdgeInsets.all(6),decoration:BoxDecoration(color:const Color(0xFFF7F7F2),borderRadius:BorderRadius.circular(10)),child:line.image.isEmpty?const Icon(Icons.shopping_bag_outlined):Image.network(line.image,fit:BoxFit.contain,errorBuilder:(_,_,_)=>const Icon(Icons.image_outlined))),const SizedBox(width:12),Expanded(child:Text(line.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w500))),const SizedBox(width:8),Text('×${line.quantity}',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))])),
   const Divider(height:24),Row(children:[Expanded(child:Text(l.total,style:Theme.of(context).textTheme.titleMedium)),Directionality(textDirection:TextDirection.ltr,child:Text('\\$${total.toStringAsFixed(2)}',style:Theme.of(context).textTheme.titleMedium))]),
   const SizedBox(height:10),Align(alignment:AlignmentDirectional.centerEnd,child:TextButton.icon(key:Key('delete-cart-${cart.id}'),onPressed:canDelete?()=>context.read<CartsBloc>().add(CartsEvent.deleteCartRequested(cart.id)):null,icon:const Icon(Icons.delete_outline,size:17),label:Text(l.simulateDelete,style:const TextStyle(fontSize:11)))),
  ])));
 }
}''')
