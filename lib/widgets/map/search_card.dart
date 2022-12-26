import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/widgets/common/logo.dart';

import '../../providers/providers.dart';

class SearchCard extends StatefulHookConsumerWidget {
  const SearchCard({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends ConsumerState<SearchCard> {
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(placeProvider);

    final textController = useTextEditingController(
      text: searchState.searchQuery,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      // Decoration should be card shadow
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.5),
            spreadRadius: -5,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 60,
                  child: Card(
                    margin: EdgeInsets.zero,
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
                            child: searchState.selectedPlace == null
                                ? TextField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search',
                                    ),
                                    controller: textController,
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        ref
                                            .read(placeProvider.notifier)
                                            .clearSearchQuery();
                                      } else {
                                        ref
                                            .read(placeProvider.notifier)
                                            .searchPlaces(value);
                                      }
                                    },
                                  )
                                : Text(
                                    textController.text,
                                    maxLines: 1,
                                  ),
                          ),
                          if (textController.text != "")
                            IconButton(
                              onPressed: () {
                                if (searchState.selectedPlace != null) {
                                  ref
                                      .read(placeProvider.notifier)
                                      .clearSelectedPlace();
                                } else {
                                  ref
                                      .read(placeProvider.notifier)
                                      .clearSearchQuery();

                                  textController.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // If loading, show loading indicator
            if (searchState.isLoading)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: LinearProgressIndicator(
                    minHeight: 5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
