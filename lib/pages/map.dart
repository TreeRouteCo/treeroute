import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:treeroute/widgets/common/user_circle.dart';
import 'package:treeroute/widgets/map/bottom_dynamic.dart';
import 'package:wakelock/wakelock.dart';
import '../providers/providers.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/map/focus_on_map_fab.dart';
//import '../widgets/map/speed_indicator.dart';

class MapPage extends StatefulHookConsumerWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  Widget build(BuildContext context) {
    final locationStateNotifier = ref.read(locationProvider.notifier);

    if (locationStateNotifier.darkModeMap != null) {
      if (locationStateNotifier.darkModeMap! &&
          Theme.of(context).brightness == Brightness.light) {
        locationStateNotifier.loadCustomMapStyle(false);
      } else if (!locationStateNotifier.darkModeMap! &&
          Theme.of(context).brightness == Brightness.dark) {
        locationStateNotifier.loadCustomMapStyle(true);
      }
    }

    Wakelock.enable();

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: HereMap(onMapCreated: _onMapCreated),
              ),
              //const AppBarCard(),

              const Positioned(
                top: 25,
                right: 25,
                child: FocusOnMapFab(),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomDynamicCard(),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: UserCircle(
                  key: Key("map-user-circle"),
                ),
              ),
              /*if (locationState.latestLocation?.speed != null &&
                  locationState.isLocating)
                const Positioned(
                  bottom: 340,
                  left: 20,
                  child: SpeedIndicator(),
                ),*/
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) async {
    final locationState = ref.read(locationProvider);
    final locationStateNotifier = ref.read(locationProvider.notifier);

    ref.read(locationProvider).mapController = hereMapController;

    locationStateNotifier
        .loadCustomMapStyle(Theme.of(context).brightness == Brightness.dark);

    hereMapController.gestures.panListener = PanListener((p0, p1, p2, p3) {
      ref.read(locationProvider.notifier).shouldNotFly();
    });
    hereMapController.gestures.doubleTapListener = DoubleTapListener((p0) {
      ref.read(locationProvider.notifier).shouldNotFly();
    });
    hereMapController.gestures.pinchRotateListener =
        PinchRotateListener((p0, p1, p2, p3, p4) {
      ref.read(locationProvider.notifier).shouldNotFly();
    });
    hereMapController.gestures.twoFingerPanListener =
        TwoFingerPanListener((p0, p1, p2, p3) {
      ref.read(locationProvider.notifier).shouldNotFly();
    });

    hereMapController.camera.lookAtPointWithMeasure(
        // Stanford University coordinates
        GeoCoordinates(37.4241, -122.1661),
        MapMeasure(MapMeasureKind.zoomLevel, 15));
    hereMapController.setWatermarkPlacement(
        WatermarkPlacement.bottomCenter, 13);

    late final PermissionStatus permissionStatus;

    if (locationState.permissionState == null) {
      permissionStatus = await locationStateNotifier.checkPermission();
    }

    if (!locationState.isLocating &&
        (permissionStatus == PermissionStatus.granted ||
            permissionStatus == PermissionStatus.grantedLimited)) {
      locationStateNotifier.startLocating();
    } else if (permissionStatus == PermissionStatus.denied ||
        permissionStatus == PermissionStatus.deniedForever) {
      // ignore: use_build_context_synchronously
      locationStateNotifier.launchPermission(context);
    }
  }
}
