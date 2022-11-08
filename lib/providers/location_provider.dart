// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:isolate';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart' as here_core;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart' as here_map;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:here_sdk/private/keys.dart';

import '../theme/light_theme.dart';
import '../widgets/common/location_access_expl.dart';
import 'providers.dart';

class LocationState {
  bool isLocating;
  PermissionStatus? permissionState;
  here_map.HereMapController? mapController;
  LocationData? latestLocation;
  Location locator;
  bool shouldFly;
  List<here_core.GeoCoordinates> lastLines;

  LocationState({
    required this.isLocating,
    this.permissionState,
    this.mapController,
    this.latestLocation,
    required this.locator,
    this.shouldFly = true,
    required this.lastLines,
  });

  LocationState copyWith({
    bool? isLocating,
    PermissionStatus? permissionState,
    bool? isAwaitingPermissions,
    here_map.HereMapController? mapController,
    LocationData? latestLocation,
    Location? locator,
    bool? shouldFly,
    List<here_core.GeoCoordinates>? lastLines,
  }) {
    return LocationState(
      isLocating: isLocating ?? this.isLocating,
      permissionState: permissionState ?? this.permissionState,
      mapController: mapController ?? this.mapController,
      latestLocation: latestLocation ?? this.latestLocation,
      locator: locator ?? this.locator,
      shouldFly: shouldFly ?? this.shouldFly,
      lastLines: lastLines ?? this.lastLines,
    );
  }

  @override
  String toString() {
    return 'LocationState(isLocating: $isLocating, permissionState: $permissionState, mapController: $mapController, latestLocation: $latestLocation, locator: $locator, shouldFly: $shouldFly, lastLines: $lastLines)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationState &&
        other.isLocating == isLocating &&
        other.permissionState == permissionState &&
        other.mapController == mapController &&
        other.locator == locator &&
        other.latestLocation == latestLocation &&
        other.shouldFly == shouldFly &&
        listEquals(other.lastLines, lastLines);
  }

  @override
  int get hashCode {
    return isLocating.hashCode ^
        permissionState.hashCode ^
        mapController.hashCode ^
        latestLocation.hashCode ^
        locator.hashCode ^
        shouldFly.hashCode ^
        lastLines.hashCode;
  }
}

class LocationProvider extends StateNotifier<LocationState> {
  LocationProvider(this.ref)
      : super(LocationState(
          isLocating: false,
          permissionState: PermissionStatus.denied,
          lastLines: [],
          locator: Location(),
        ));
  final Ref ref;
  here_map.LocationIndicator? _locIndicator;
  here_map.MapPolyline? _mapPolyline;

  Future<PermissionStatus> checkPermission() async {
    state = state.copyWith(
      permissionState: await state.locator.hasPermission(),
    );

    return state.permissionState!;
  }

  Future<void> launchPermission(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        isDismissible: false,
        //isScrollControlled: true,
        builder: (_) {
          return LocationAccessCard(callback: () async {
            Beamer.of(context).popRoute();
            final status = await state.locator.requestPermission();

            if (status == PermissionStatus.deniedForever) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Access to Location"),
                      content: const Text(
                          "It seems you have permanently denied TreeRoute access to your location."
                          " To be able to track your drive we need permission to access it."
                          " Click the button below to open the settings, then change the location"
                          " permission to 'While in Use'"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // TODO: Open App Settings
                            Beamer.of(context).popRoute();
                          },
                          child: const Text("Open App Settings"),
                        ),
                        TextButton(
                          onPressed: () {
                            Beamer.of(context).popRoute();
                          },
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  });
            }
            state = state.copyWith(permissionState: status);
          });
        });
  }

  Future<void> stopAndDispose({clear = false}) async {
    if (_locIndicator != null) {
      state.mapController?.removeLifecycleListener(_locIndicator!);
    }
    _locIndicator = null;
    state = state.copyWith(isLocating: false);
    if (clear) {
      state = LocationState(
        isLocating: false,
        lastLines: [],
        locator: Location(),
      );
    }
  }

  void shouldFly({bool doNow = true}) {
    state = state.copyWith(shouldFly: true);
    if (doNow && state.latestLocation != null) {
      _updateMap(null, state.latestLocation!);
    }
  }

  void _updateMap(LocationData? previous, LocationData next) {
    if (state.mapController != null) {
      final nextCoordinate =
          here_core.GeoCoordinates(next.latitude!, next.longitude!);

      final previousCoordinate = previous == null
          ? null
          : here_core.GeoCoordinates(previous.latitude!, previous.longitude!);

      final loc = here_core.Location.withCoordinates(nextCoordinate);
      loc.time = DateTime.now();
      loc.bearingInDegrees = next.heading;

      _locIndicator?.updateLocation(loc);

      if (previousCoordinate == null ||
          nextCoordinate.distanceTo(previousCoordinate) > 1) {
        if (state.shouldFly) {
          if (previousCoordinate == null) {
            state.mapController?.camera.lookAtPointWithMeasure(nextCoordinate,
                here_map.MapMeasure(here_map.MapMeasureKind.distance, 1500));
          } else {
            state.mapController?.camera
                .flyToWithOptionsAndGeoOrientationAndDistance(
                    nextCoordinate,
                    here_core.GeoOrientationUpdate(loc.bearingInDegrees, 60),
                    1500,
                    here_map.MapCameraFlyToOptions.withDefaults());
          }
        }
        state.lastLines.add(nextCoordinate);
        if (state.lastLines.length > 5000) {
          state.lastLines.removeAt(0);
        }
        final mapScene = state.mapController?.mapScene;

        final mapPolylineNew = _createPolyline(state.lastLines);
        if (mapPolylineNew != null) {
          mapScene?.addMapPolyline(mapPolylineNew);
        }
        if (_mapPolyline != null) {
          mapScene?.removeMapPolyline(_mapPolyline!);
        }
        _mapPolyline = mapPolylineNew;
      }
    }
  }

  here_map.MapPolyline? _createPolyline(
    List<here_core.GeoCoordinates> coordinates,
  ) {
    here_core.GeoPolyline geoPolyline;
    try {
      geoPolyline = here_core.GeoPolyline(coordinates);
    } on InstantiationException {
      // Thrown when less than two vertices.
      return null;
    }

    double widthInPixels = 20;
    Color lineColor = lightTheme().primaryColor;
    here_map.MapPolyline mapPolyline =
        here_map.MapPolyline(geoPolyline, widthInPixels, lineColor);

    return mapPolyline;
  }


  void disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    await SDKNativeEngine.sharedInstance?.dispose();
    here_core.SdkContext.release();
  }
}
