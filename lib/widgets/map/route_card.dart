import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/providers.dart';

class RouteCard extends StatefulHookConsumerWidget {
  const RouteCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RouteCardState();
}

class _RouteCardState extends ConsumerState<RouteCard> {
  @override
  Widget build(BuildContext context) {
    final route = ref.watch(routingProvider);
    final routeNotifier = ref.read(routingProvider.notifier);

    return SizedBox(
      height: 100,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Total Distance",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    "${route.distanceInMeters}m",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              /*Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_sharp,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Total Route Time",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    routeNotifier.formatTime(route.durationInSecs!),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),*/
              IconButton(
                onPressed: () {
                  routeNotifier.clearRoutes();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
