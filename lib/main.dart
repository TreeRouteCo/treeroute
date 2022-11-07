import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/pages/map.dart';
import 'package:treeroute/theme/dark_theme.dart';
import 'package:treeroute/theme/light_theme.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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

    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: ref.watch(beamerDelegateProvider),
      title: 'TreeRoute',
      theme: lightTheme(),
      darkTheme: darkTheme(),
    );
  }
}
