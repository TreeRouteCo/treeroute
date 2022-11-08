import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:wakelock/wakelock.dart';
import '../providers/providers.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/map/appbar_card.dart';
import '../widgets/map/focus_on_map_fab.dart';
import '../widgets/map/speed_indicator.dart';
import '../widgets/map/tracking_status_card.dart';

class MapPage extends StatefulHookConsumerWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

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
              const AppBarCard(),
              if (!locationState.shouldFly && locationState.isLocating)
                const Positioned(
                  bottom: 90,
                  right: 25,
                  child: FocusOnMapFab(),
                ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TrackingStatusCard(),
              ),
              if (locationState.latestLocation?.speed != null &&
                  locationState.isLocating)
                const Positioned(
                  bottom: 90,
                  left: 20,
                  child: SpeedIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) async {
    final locationState = ref.read(locationProvider);
    final locationStateNotifier = ref.read(locationProvider.notifier);

    hereMapController.mapScene.loadSceneForMapScheme(
        Theme.of(context).brightness == Brightness.light
            ? MapScheme.normalDay
            : MapScheme.normalNight, (MapError? error) {
      if (error != null) {
        return;
      }
    });

    var shouldFly = ref.read(locationProvider).shouldFly;

    hereMapController.gestures.panListener = PanListener((p0, p1, p2, p3) {
      if (mounted && shouldFly) {
        setState(() {
          ref.read(locationProvider).shouldFly = false;
        });
      }
    });
    hereMapController.gestures.doubleTapListener = DoubleTapListener((p0) {
      if (mounted && shouldFly) {
        ref.read(locationProvider).shouldFly = false;
      }
    });
    hereMapController.gestures.pinchRotateListener =
        PinchRotateListener((p0, p1, p2, p3, p4) {
      if (mounted && shouldFly) {
        ref.read(locationProvider).shouldFly = false;
      }
    });
    hereMapController.gestures.twoFingerPanListener =
        TwoFingerPanListener((p0, p1, p2, p3) {
      if (mounted && shouldFly) {
        ref.read(locationProvider).shouldFly = false;
      }
    });

    hereMapController.camera.lookAtPointWithMeasure(
        // Stanford University coordinates
        GeoCoordinates(37.42796133580664, -122.085749655962),
        MapMeasure(MapMeasureKind.zoomLevel, 15));
    hereMapController.setWatermarkPlacement(
        WatermarkPlacement.bottomCenter, 13);

    ref.read(locationProvider).mapController = hereMapController;

    late final PermissionStatus permissionStatus;

    if (locationState.permissionState == null) {
      permissionStatus = await locationStateNotifier.checkPermission();
    }

    if (!locationState.isLocating &&
        (permissionStatus == PermissionStatus.granted ||
            permissionStatus == PermissionStatus.grantedLimited)) {
      locationStateNotifier.startLocating();
    }
  }
}
