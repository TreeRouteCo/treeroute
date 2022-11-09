import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:here_sdk/search.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/widgets/common/logo.dart';

import '../../providers/providers.dart';

class SearchCard extends StatefulHookConsumerWidget {
  const SearchCard({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends ConsumerState<SearchCard> {
  List<Suggestion> suggestions = [];
  Suggestion? selectedSuggestion;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider.notifier);
    final routingStateNotifier = ref.watch(routingProvider.notifier);
    final routingState = ref.watch(routingProvider);

    final textController = useTextEditingController();

    return SizedBox(
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BrandIcon(
                      width: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search',
                        ),
                        onChanged: (value) {
                          ref
                              .read(locationProvider.notifier)
                              .searchSuggestions(value, ((error, sugg) {
                            setState(() {
                              suggestions = sugg ?? [];
                            });
                          }));
                        },
                        onTap: () {
                          //ref.read(locationProvider.notifier).search();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: suggestions.isEmpty ? 0 : 250,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // Search results
                child: selectedSuggestion == null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: suggestions.length + 1,
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
                            title: Text(suggestions[index].title),
                            subtitle: Text(
                                suggestions[index].place?.address.addressText ??
                                    ''),
                            onTap: () {
                              selectedSuggestion = suggestions[index];
                              locationState.addMarker(
                                  selectedSuggestion!.place!.geoCoordinates!,
                                  shouldFly: true);
                              setState(() {});
                            },
                          );
                        },
                      )
                    : Column(
                        children: [
                          // Show selected suggestion, as title, address and button to fly to it
                          // Back button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  selectedSuggestion = null;
                                  setState(() {});
                                },
                              ),
                              Text(
                                selectedSuggestion!.title,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(
                                width: 48,
                              ),
                            ],
                          ),
                          Text(selectedSuggestion!.place?.address.addressText ??
                              ''),
                          const SizedBox(
                            height: 20,
                          ),
                          // Bike and walk buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(routingProvider.notifier).addRoute(
                                        endCoords: selectedSuggestion!
                                            .place!.geoCoordinates!,
                                        isBiking: true,
                                      );
                                  //locationState.routeTo(selectedSuggestion!.place!);
                                },
                                child: const Text('Bike'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(routingProvider.notifier).addRoute(
                                        endCoords: selectedSuggestion!
                                            .place!.geoCoordinates!,
                                        isBiking: false,
                                      );
                                  //locationState.routeTo(selectedSuggestion!.place!);
                                },
                                child: const Text('Walk'),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
