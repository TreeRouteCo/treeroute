import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';

class SelectedPlaceCard extends StatefulHookConsumerWidget {
  const SelectedPlaceCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectedPlaceCardState();
}

class _SelectedPlaceCardState extends ConsumerState<SelectedPlaceCard> {
  @override
  Widget build(BuildContext context) {
    final search = ref.watch(placeProvider);
    final searchNotifier = ref.read(placeProvider.notifier);

    final locationNotifier = ref.read(locationProvider.notifier);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                searchNotifier.clearSelectedPlace();
              },
            ),
            Expanded(
              child: Text(
                search.selectedPlace!.name ?? "No Name",
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(
              width: 48,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                locationNotifier.startNavModeCamera();

                ref.read(routingProvider.notifier).addRoute(
                      endCoords: search.selectedPlace!.geoCoordinates,
                      isBiking: false,
                    );
              },
              icon: const Icon(Icons.directions),
              label: const Text('Navigate'),
            ),
          ],
        ),
      ],
    );
  }
}
