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
    final locationState = ref.watch(locationProvider.notifier);
    final searchState = ref.watch(searchProvider);
    final searchStateNotifier = ref.watch(searchProvider.notifier);

    final textController = useTextEditingController(
      text: searchState.searchQuery,
    );

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
                        controller: textController,
                        onChanged: (value) {
                          ref
                              .read(searchProvider.notifier)
                              .searchSuggestions(value, (error, sugg) {});
                        },
                        onTap: () {
                          //ref.read(locationProvider.notifier).search();
                        },
                      ),
                    ),
                    if (textController.text != "")
                      IconButton(
                        onPressed: () {
                          ref.read(searchProvider.notifier).clearSearch();
                          textController.clear();
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
    );
  }
}
