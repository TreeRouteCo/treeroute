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
    final search = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

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
            height: (search.suggestions.isEmpty &&
                    search.selectedSuggestion == null)
                ? 0
                : search.selectedSuggestion != null
                    ? 100
                    : 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Search results
              child: search.selectedSuggestion == null
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: search.suggestions.length + 1,
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
                          title: Text(search.suggestions[index].title),
                          subtitle: Text(search.suggestions[index].place
                                  ?.address.addressText ??
                              ''),
                          onTap: () {
                            searchNotifier
                                .selectSuggestion(search.suggestions[index]);
                            locationNotifier.addMarker(
                              search.suggestions[index].place!.geoCoordinates!,
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
                                searchNotifier.clearSelectedSuggestion();
                              },
                            ),
                            Expanded(
                              child: Text(
                                search.selectedSuggestion!.title,
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
                                      endCoords: search.selectedSuggestion!
                                          .place!.geoCoordinates!,
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
