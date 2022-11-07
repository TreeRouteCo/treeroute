import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';

class FocusOnMapFab extends HookConsumerWidget {
  const FocusOnMapFab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(locationProvider).shouldFly;
    return FloatingActionButton(
      onPressed: () {
        ref.read(locationProvider.notifier).shouldFly();
      },
      child: const Icon(Icons.my_location_rounded),
    );
  }
}
