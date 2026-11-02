import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleany Store'**
  String get appTitle;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get catalog;

  /// No description provided for @carts.
  ///
  /// In en, this message translates to:
  /// **'Carts'**
  String get carts;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get users;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'cleany / store'**
  String get brand;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'A little everyday discovery.'**
  String get tagline;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next favorite.'**
  String get catalogTitle;

  /// No description provided for @catalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thoughtful picks. Real API. Built with Cleany.'**
  String get catalogSubtitle;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @priceSort.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get priceSort;

  /// No description provided for @featuredSort.
  ///
  /// In en, this message translates to:
  /// **'Featured order'**
  String get featuredSort;

  /// No description provided for @spotlight.
  ///
  /// In en, this message translates to:
  /// **'THE DAILY FIND'**
  String get spotlight;

  /// No description provided for @viewProduct.
  ///
  /// In en, this message translates to:
  /// **'Take a closer look'**
  String get viewProduct;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Create demo cart'**
  String get addToCart;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetails;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get noResults;

  /// No description provided for @noProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Try another search or category.'**
  String get noProductsHint;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the store. Check your connection.'**
  String get networkError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Username or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @invalidData.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unexpected response.'**
  String get invalidData;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'The demo service is temporarily unavailable.'**
  String get serverError;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'LIVE API DEMO'**
  String get demo;

  /// No description provided for @demoNotice.
  ///
  /// In en, this message translates to:
  /// **'Fake Store simulates writes. New carts and deletions are not persisted on its server.'**
  String get demoNotice;

  /// No description provided for @cartsTitle.
  ///
  /// In en, this message translates to:
  /// **'A peek inside the bag.'**
  String get cartsTitle;

  /// No description provided for @cartsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore demo carts, with every item at a glance.'**
  String get cartsSubtitle;

  /// No description provided for @newCart.
  ///
  /// In en, this message translates to:
  /// **'Your new demo cart'**
  String get newCart;

  /// No description provided for @creatingCart.
  ///
  /// In en, this message translates to:
  /// **'Creating your demo cart…'**
  String get creatingCart;

  /// No description provided for @cartCreated.
  ///
  /// In en, this message translates to:
  /// **'Cart created successfully'**
  String get cartCreated;

  /// No description provided for @cartLabel.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartLabel;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @simulateDelete.
  ///
  /// In en, this message translates to:
  /// **'Simulate delete'**
  String get simulateDelete;

  /// No description provided for @cartDeleted.
  ///
  /// In en, this message translates to:
  /// **'Removed from this view. The API dataset resets on refresh.'**
  String get cartDeleted;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet the demo community.'**
  String get usersTitle;

  /// No description provided for @usersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Public sample profiles. No passwords are displayed.'**
  String get usersSubtitle;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get searchUsers;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your store.'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a public Fake Store demo account.'**
  String get signInSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @useDemoAccount.
  ///
  /// In en, this message translates to:
  /// **'Use public demo account'**
  String get useDemoAccount;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'You’re signed in'**
  String get signedIn;

  /// No description provided for @sessionMemory.
  ///
  /// In en, this message translates to:
  /// **'You are using a public demo account. Your session clears when the app closes.'**
  String get sessionMemory;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest · demo user #1'**
  String get guest;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get language;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Scaffolded with local CLEANY 2.0.2'**
  String get madeWith;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @browseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get browseProducts;

  /// No description provided for @emptyCarts.
  ///
  /// In en, this message translates to:
  /// **'No carts to show'**
  String get emptyCarts;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
