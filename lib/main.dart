import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/private/keys.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/pages/map.dart';
import 'package:treeroute/theme/dark_theme.dart';
import 'package:treeroute/theme/light_theme.dart';

void main() async {
  await _initializeHERESDK();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<void> _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

  // Set your credentials for the HERE SDK.
  String accessKeyId = HERESDKKeys.appKeyId;
  String accessKeySecret = HERESDKKeys.appKeySecret;
  SDKOptions sdkOptions =
      SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: AppWrapper());
  }
}

final Provider<BeamerDelegate> beamerDelegateProvider =
    Provider<BeamerDelegate>(
  (ref) => BeamerDelegate(
    initialPath: "/map",
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/map': (context, state, data) => const MapPage(),
      },
    ),
  ),
);

class AppWrapper extends HookConsumerWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BeamerProvider(
      routerDelegate: ref.read(beamerDelegateProvider),
      child: const NavigationWrapper(),
    );
  }
}

class NavigationWrapper extends HookConsumerWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /*WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.read(authProvider.notifier).tryAutoLogin();
      },
    );

    ref.listen(authProvider, (AuthState? previous, AuthState next) {
      if (next.isAuthing) {
        return;
      }
      if (previous?.token != null && next.token == null) {
        Beamer.of(context).beamToNamed("/loginWithPin");
      } else if (next.token != null && (previous?.isAuthing ?? false)) {
        Beamer.of(context).beamToNamed("/locSharing");
      }
    });*/

    //ref.read(locationProvider.notifier).init();

    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: ref.watch(beamerDelegateProvider),
      title: 'TreeRoute',
      theme: lightTheme(),
      //darkTheme: darkTheme(),
    );
  }
}
