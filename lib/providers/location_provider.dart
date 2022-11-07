// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:background_location/background_location.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart' as here_core;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart' as here_map;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:here_sdk/private/keys.dart';

import '../theme/light_theme.dart';
import '../widgets/common/location_access_expl.dart';
import 'providers.dart';

class LocationState {
  bool isLocating;
  bool isPermissionGranted;
  bool isAwaitingPermissions;
  here_map.HereMapController? mapController;
  Location? latestLocation;
  bool shouldFly;
  List<here_core.GeoCoordinates> lastLines;

  LocationState({
    required this.isLocating,
    required this.isPermissionGranted,
    required this.isAwaitingPermissions,
    this.mapController,
    this.latestLocation,
    this.shouldFly = true,
    required this.lastLines,
  });

  LocationState copyWith({
    bool? isLocating,
    bool? isPermissionGranted,
    bool? isAwaitingPermissions,
    here_map.HereMapController? mapController,
    Location? latestLocation,
    bool? shouldFly,
    List<here_core.GeoCoordinates>? lastLines,
  }) {
    return LocationState(
      isLocating: isLocating ?? this.isLocating,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isAwaitingPermissions:
          isAwaitingPermissions ?? this.isAwaitingPermissions,
      mapController: mapController ?? this.mapController,
      latestLocation: latestLocation ?? this.latestLocation,
      shouldFly: shouldFly ?? this.shouldFly,
      lastLines: lastLines ?? this.lastLines,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isLocating': isLocating,
      'isPermissionGranted': isPermissionGranted,
      'isAwaitingPermissions': isAwaitingPermissions,
      //'mapController': mapController?.toMap(),
      'latestLocation': latestLocation?.toMap(),
      'shouldFly': shouldFly,
      //'lastLines': lastLines.map((x) => x.toMap()).toList(),
    };
  }

  factory LocationState.fromMap(Map<String, dynamic> map) {
    return LocationState(
        isLocating: map['isLocating'] ?? false,
        isPermissionGranted: map['isPermissionGranted'] ?? false,
        isAwaitingPermissions: map['isAwaitingPermissions'] ?? false,
        //mapController: map['mapController'] != null ? here_map.HereMapController.fromMap(map['mapController']) : null,
        //latestLocation: map['latestLocation'] != null ? Location.fromMap(map['latestLocation']) : null,
        shouldFly: map['shouldFly'] ?? false,
        lastLines: []
        //lastLines: List<here_core.GeoCoordinates>.from(map['lastLines']?.map((x) => here_core.GeoCoordinates.fromMap(x))),
        );
  }

  String toJson() => json.encode(toMap());

  factory LocationState.fromJson(String source) =>
      LocationState.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LocationState(isLocating: $isLocating, isPermissionGranted: $isPermissionGranted, isAwaitingPermissions: $isAwaitingPermissions, mapController: $mapController, latestLocation: $latestLocation, shouldFly: $shouldFly, lastLines: $lastLines)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationState &&
        other.isLocating == isLocating &&
        other.isPermissionGranted == isPermissionGranted &&
        other.isAwaitingPermissions == isAwaitingPermissions &&
        other.mapController == mapController &&
        other.latestLocation == latestLocation &&
        other.shouldFly == shouldFly &&
        listEquals(other.lastLines, lastLines);
  }

  @override
  int get hashCode {
    return isLocating.hashCode ^
        isPermissionGranted.hashCode ^
        isAwaitingPermissions.hashCode ^
        mapController.hashCode ^
        latestLocation.hashCode ^
        shouldFly.hashCode ^
        lastLines.hashCode;
  }
}

class LocationProvider extends StateNotifier<LocationState> {
  LocationProvider(this.ref)
      : super(LocationState(
          isLocating: false,
          isPermissionGranted: false,
          isAwaitingPermissions: true,
          lastLines: [],
        ));
  final Ref ref;
  here_map.LocationIndicator? _locIndicator;
  here_map.MapPolyline? _mapPolyline;

  Future<bool> checkPremission() async {
    if (!state.isAwaitingPermissions) return state.isPermissionGranted;
    try {
      final premissionStatus = await Permission.locationWhenInUse.status;
      if (premissionStatus.isGranted || premissionStatus.isLimited) {
        state = state.copyWith(
            isPermissionGranted: true, isAwaitingPermissions: false);
        return true;
      } else {
        state = state.copyWith(
            isPermissionGranted: false, isAwaitingPermissions: false);
      }
      return false;
    } catch (e) {
      state = state.copyWith(
          isPermissionGranted: false, isAwaitingPermissions: false);
      return false;
    }
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
            final status = await Permission.locationWhenInUse.request();

            if (status.isPermanentlyDenied) {
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
                            openAppSettings();
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
              state = state.copyWith(isPermissionGranted: false);
            } else if (status.isGranted || status.isLimited) {
              state = state.copyWith(isPermissionGranted: true);
            } else {
              state = state.copyWith(isPermissionGranted: false);
            }
          });
        });
  }

  Future<void> beginTracking() async {
    if (state.isLocating) return;

    BackgroundLocation.setAndroidNotification(
      title: "TreeRoute is accessing your location",
      message: "Click here to open TreeRoute.",
      icon: "@mipmap/launcher_icon",
    );
    BackgroundLocation.startLocationService(distanceFilter: 1);
    state = state.copyWith(isLocating: true);

    BackgroundLocation.getLocationUpdates((location) {
      final oldLoc = state.latestLocation;
      state = state.copyWith(latestLocation: location);
      _updateMap(oldLoc, location);
    });
    _locIndicator ??= here_map.LocationIndicator();
    state.mapController?.addLifecycleListener(_locIndicator!);
  }

  Future<void> stopAndDispose({clear = false}) async {
    BackgroundLocation.stopLocationService();
    if (_locIndicator != null) {
      state.mapController?.removeLifecycleListener(_locIndicator!);
    }
    _locIndicator = null;
    state = state.copyWith(isLocating: false);
    if (clear) {
      state = LocationState(
          isLocating: false,
          isPermissionGranted: false,
          isAwaitingPermissions: true,
          lastLines: []);
    }
  }

  void shouldFly({bool doNow = true}) {
    state = state.copyWith(shouldFly: true);
    if (doNow && state.latestLocation != null) {
      _updateMap(null, state.latestLocation!);
    }
  }

  void _updateMap(Location? previous, Location next) {
    if (state.mapController != null) {
      final nextCoordinate =
          here_core.GeoCoordinates(next.latitude!, next.longitude!);

      final previousCoordinate = previous == null
          ? null
          : here_core.GeoCoordinates(previous.latitude!, previous.longitude!);

      final loc = here_core.Location.withCoordinates(nextCoordinate);
      loc.time = DateTime.now();
      loc.bearingInDegrees = next.bearing;

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

  void init() async {
    // Needs to be called before accessing SDKOptions to load necessary libraries.
    here_core.SdkContext.init(here_core.IsolateOrigin.main);

    // Set your credentials for the HERE SDK.
    String accessKeyId = HERESDKKeys.appKeyId;
    String accessKeySecret = HERESDKKeys.appKeySecret;
    SDKOptions sdkOptions =
        SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

    try {
      await SDKNativeEngine.makeSharedInstance(sdkOptions);
    } on InstantiationException {
      throw Exception("Failed to initialize the HERE SDK.");
    }
  }

  void disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    await SDKNativeEngine.sharedInstance?.dispose();
    here_core.SdkContext.release();
  }
}
