import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/providers.dart';

class SpeedIndicator extends StatefulHookConsumerWidget {
  const SpeedIndicator({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SpeedIndicatorState();
}

class _SpeedIndicatorState extends ConsumerState<SpeedIndicator> {
  // TODO: Add settings for this
  bool isMetric = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        isMetric = !isMetric;
        //prefs?.setBool("isMetric", isMetric);
        setState(() {});
      },
      child: Container(
        width: 65,
        height: 65,
        padding: Theme.of(context).cardTheme.margin,
        child: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (locationState.latestLocation!.speed! *
                            (isMetric ? 3.6 : 2.23694))
                        .toInt()
                        .toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 22),
                  ),
                  Text(
                    isMetric ? "kmph" : "mph",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
