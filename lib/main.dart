import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';
import 'simple_bloc_observer.dart';
import 'auth/bloc/user_bloc.dart';
import 'router.dart';
import 'theme.dart';

void handleFlutterError(FlutterErrorDetails details) {
  FlutterError.presentError(details);
  // Optionally log to a service or file here.
}

bool handlePlatformError(Object error, StackTrace stack) {
  // Optionally log to a service or file here.
  return true; // Prevents the app from crashing.
}

void setupGlobalErrorHandling() {
  FlutterError.onError = handleFlutterError;
  PlatformDispatcher.instance.onError = handlePlatformError;
}

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    final emulatorHost =
        (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
            ? '10.0.2.2'
            : 'localhost';
    try {
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
      await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  Bloc.observer = const SimpleBlocObserver();
  runApp(BlocProvider<UserBloc>(create: (context) => UserBloc(), child: App()));
}

class App extends StatelessWidget {
  final _appRouter = AppRouter();
  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.config(),
    );
  }
}
