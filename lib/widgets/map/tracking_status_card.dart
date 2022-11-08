import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';

import '../../providers/providers.dart';

class TrackingStatusCard extends HookConsumerWidget {
  const TrackingStatusCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return Card(
      margin: const EdgeInsets.all(15),
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locationState.isLocating
                    ? "Location is Active"
                    : "Location is Stopped",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
