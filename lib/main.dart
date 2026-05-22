import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/auth/application/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  const tokenKey = 'jwt_token';

  var initialToken = await secureStorage.read(key: tokenKey);
  final legacyToken = sharedPreferences.getString(tokenKey);
  if ((initialToken == null || initialToken.isEmpty) &&
      legacyToken != null &&
      legacyToken.isNotEmpty) {
    await secureStorage.write(key: tokenKey, value: legacyToken);
    await sharedPreferences.remove(tokenKey);
    initialToken = legacyToken;
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        secureStorageProvider.overrideWithValue(secureStorage),
        initialTokenProvider.overrideWithValue(initialToken),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'GreenStone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
