import 'dart:io';

// لم نعد بحاجة إلى yaml_edit أو yaml لأن Dart سيتكفل بالعملية

Future<void> initializeAddPackages({bool updatePackages = true}) async {
  print('📦 Adding packages (resolving latest compatible versions)...');

  // ملاحظة هامة: يجب تشغيلها بالتسلسل وليس باستخدام Future.wait
  // لأن تشغيل أمري pub add في نفس الوقت سيؤدي إلى خطأ (File Lock)
  await addDependenciesEfficiently(corePackages, isDev: false);
  await addDependenciesEfficiently(devPackages, isDev: true);

  // أمر 'pub add' يقوم بعمل 'pub get' تلقائياً، لذلك قد لا تحتاج لتشغيله مرة أخرى
  // ولكن تركناه إذا كنت ترغب في التأكيد.
  if (updatePackages) {
    print("⏳ Finalizing...");
    final result = await Process.run('dart', ['pub', 'get'], runInShell: true);
    if (result.exitCode != 0) {
      print("⚠️ Warning during pub get:\n${result.stderr}");
    }
  }
}

Future<void> addDependenciesEfficiently(
  List<String> packages, {
  required bool isDev,
}) async {
  if (packages.isEmpty) return;

  final sectionName = isDev ? 'dev_dependencies' : 'dependencies';

  final args = ['pub', 'add'];
  if (isDev) {
    args.add('--dev');
  }
  args.addAll(packages);

  print(
    "⚙️  Resolving and adding ${packages.length} packages to $sectionName...",
  );

  // إضافة runInShell: true هي السر لدعم الويندوز بشكل مثالي
  final result = await Process.run(
    'dart',
    args,
    runInShell: true, // 👈 التعديل هنا
  );

  if (result.exitCode == 0) {
    print("✅ Successfully added packages to $sectionName");
  } else {
    throw Exception(
      "❌ Failed to add packages to $sectionName:\n${result.stderr}",
    );
  }
}

//------------------------- packages dependencies ------------------------------
// قمنا بتحويلها إلى List of Strings لأننا لا نحتاج لتحديد الإصدار
const List<String> corePackages = [
  "cupertino_icons",
  "flutter_dotenv",
  "multiple_result",
  "flutter_bloc",
  "bloc",
  "dart_mappable",
  "dio",
  "easy_localization",
  "flutter_secure_storage",
  "sizer",
  "supabase_flutter",
  "get_storage",
  "get_it",
  "go_router",
  "injectable",
  "equatable",
  "package_info_plus",
  "device_info_plus",
  "loading_animation_widget",
  'uuid',
];

//------------------------- packages dev_dependencies --------------------------
const List<String> devPackages = [
  "flutter_lints",
  "build_runner",
  "dart_mappable_builder",
  "injectable_generator",
];
