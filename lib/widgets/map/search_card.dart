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

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Search results
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index].title),
                    subtitle: Text(
                        suggestions[index].place?.address.addressText ?? ''),
                    onTap: () {
                      print(suggestions[index].title);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
