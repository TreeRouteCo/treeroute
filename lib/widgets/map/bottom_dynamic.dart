import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';
import 'package:treeroute/widgets/map/route_card.dart';
import 'package:treeroute/widgets/map/search_card.dart';

class BottomDynamicCard extends StatefulHookConsumerWidget {
  const BottomDynamicCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomDynamicCardState();
}

class _BottomDynamicCardState extends ConsumerState<BottomDynamicCard> {
  @override
  Widget build(BuildContext context) {
    final search = ref.watch(placeProvider);
    final searchNotifier = ref.read(placeProvider.notifier);

    final locationNotifier = ref.read(locationProvider.notifier);

    final route = ref.watch(routingProvider);

    if (route.route != null) {
      return const RouteCard();
    }

    return Column(
      children: [
        const SearchCard(),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: (search.places.isEmpty && search.selectedPlace == null)
                ? 0
                : search.selectedPlace != null
                    ? 100
                    : 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Search results
              child: search.selectedPlace == null
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: search.places.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 5),
                            child: Text(
                              "Search Results",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          );
                        }
                        index--;
                        return ListTile(
                          title: Text(search.places[index].name ?? "No Name"),
                          subtitle: Text(search.places[index].address ?? ''),
                          onTap: () {
                            searchNotifier.selectPlace(search.places[index]);
                            locationNotifier.addMarker(
                              search.places[index].geoCoordinates,
                              shouldFly: true,
                            );
                            setState(() {});
                          },
                        );
                      },
                    )
                  : Column(
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
                                      endCoords:
                                          search.selectedPlace!.geoCoordinates,
                                      isBiking: false,
                                    );
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('Navigate'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
