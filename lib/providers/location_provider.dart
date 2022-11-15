import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:here_sdk/core.dart' as here_core;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/mapview.dart' as here_map;
import 'package:here_sdk/routing.dart' as here_route;
import 'package:here_sdk/search.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

import '../widgets/common/location_access_expl.dart';

class LocationState {
  bool isLocating;
  PermissionStatus? permissionState;
  here_map.HereMapController? mapController;
  SearchEngine searchEngine;
  LocationData? latestLocation;
  Location locator;
  bool shouldFly;
  List<here_core.GeoCoordinates> lastLines;
  CompassEvent? compass;
  here_route.RoutingEngine routingEngine;
  bool isInNavigationMode;

  LocationState({
    required this.isLocating,
    this.permissionState,
    this.mapController,
    this.latestLocation,
    required this.locator,
    this.shouldFly = true,
    required this.searchEngine,
    required this.lastLines,
    this.compass,
    required this.routingEngine,
    this.isInNavigationMode = false,
  });

  LocationState copyWith({
    bool? isLocating,
    PermissionStatus? permissionState,
    here_map.HereMapController? mapController,
    LocationData? latestLocation,
    Location? locator,
    bool? shouldFly,
    List<here_core.GeoCoordinates>? lastLines,
    CompassEvent? compass,
    SearchEngine? searchEngine,
    here_route.RoutingEngine? routingEngine,
    bool? isInNavigationMode,
  }) {
    return LocationState(
      isLocating: isLocating ?? this.isLocating,
      permissionState: permissionState ?? this.permissionState,
      mapController: mapController ?? this.mapController,
      latestLocation: latestLocation ?? this.latestLocation,
      locator: locator ?? this.locator,
      shouldFly: shouldFly ?? this.shouldFly,
      lastLines: lastLines ?? this.lastLines,
      compass: compass ?? this.compass,
      searchEngine: searchEngine ?? this.searchEngine,
      routingEngine: routingEngine ?? this.routingEngine,
      isInNavigationMode: isInNavigationMode ?? this.isInNavigationMode,
    );
  }

  @override
  String toString() {
    return 'LocationState(isLocating: $isLocating, permissionState: $permissionState, mapController: $mapController, latestLocation: $latestLocation, locator: $locator, shouldFly: $shouldFly, lastLines: $lastLines, compass: $compass, searchEngine: $searchEngine, routingEngine: $routingEngine, isInNavigationMode: $isInNavigationMode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationState &&
        other.isLocating == isLocating &&
        other.permissionState == permissionState &&
        other.mapController == mapController &&
        other.latestLocation == latestLocation &&
        other.locator == locator &&
        other.shouldFly == shouldFly &&
        listEquals(other.lastLines, lastLines) &&
        searchEngine == other.searchEngine &&
        routingEngine == other.routingEngine &&
        other.isInNavigationMode == isInNavigationMode &&
        other.compass == compass;
  }

  @override
  int get hashCode {
    return isLocating.hashCode ^
        permissionState.hashCode ^
        mapController.hashCode ^
        latestLocation.hashCode ^
        locator.hashCode ^
        shouldFly.hashCode ^
        lastLines.hashCode ^
        searchEngine.hashCode ^
        routingEngine.hashCode ^
        isInNavigationMode.hashCode ^
        compass.hashCode;
  }
}

class LocationProvider extends StateNotifier<LocationState> {
  LocationProvider(this.ref)
      : super(LocationState(
          isLocating: false,
          permissionState: null,
          lastLines: [],
          locator: Location(),
          searchEngine: SearchEngine(),
          routingEngine: here_route.RoutingEngine(),
        ));
  final Ref ref;
  here_map.LocationIndicator? _locIndicator;
  bool? darkModeMap;
  here_map.MapImage? _photoMapImage;

  here_core.GeoCoordinates? _selectedCoords;
  here_map.MapMarker? _selectedMarker;

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
                            perm.openAppSettings();
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
            } else {
              startLocating();
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
        searchEngine: state.searchEngine,
        routingEngine: state.routingEngine,
      );
    }
  }

  void shouldFly({bool doNow = true}) {
    state = state.copyWith(shouldFly: true);
    if (doNow && state.latestLocation != null) {
      _updateMap(state.latestLocation!);
    }
  }

  void _updateMap(LocationData next) {
    if (state.mapController != null) {
      final nextCoordinate =
          here_core.GeoCoordinates(next.latitude!, next.longitude!);

      final loc = here_core.Location.withCoordinates(nextCoordinate);
      loc.time = DateTime.now();
      loc.bearingInDegrees = state.compass?.headingForCameraMode ?? 0;

      _locIndicator?.updateLocation(loc);

      if (state.shouldFly) {
        flyTo(geoCoordinates: nextCoordinate);
      }
    }
  }

  StreamSubscription<LocationData> startLocating() {
    state.isLocating = true;

    state.locator.getLocation().then((value) {
      state = state.copyWith(latestLocation: value);
      _updateMap(value);
    });

    _locIndicator ??= here_map.LocationIndicator();
    state.mapController?.addLifecycleListener(_locIndicator!);

    FlutterCompass.events?.listen((event) {
      state = state.copyWith(compass: event);
    });

    return state.locator.onLocationChanged
        .listen((LocationData currentLocation) {
      state = state.copyWith(latestLocation: currentLocation, isLocating: true);
      _updateMap(currentLocation);
    });
  }

  void flyTo({
    required here_core.GeoCoordinates geoCoordinates,
    int durationMillis = 200,
    double bowFactor = 0,
  }) {
    if (state.isInNavigationMode) {
      flyToInNavMode(
        geoCoordinates: geoCoordinates,
        bowFactor: bowFactor,
      );
      return;
    }
    here_core.GeoCoordinatesUpdate geoCoordinatesUpdate =
        here_core.GeoCoordinatesUpdate.fromGeoCoordinates(geoCoordinates);
    here_map.MapCameraAnimation animation =
        here_map.MapCameraAnimationFactory.flyToWithOrientationAndZoom(
            geoCoordinatesUpdate,
            here_core.GeoOrientationUpdate(0, 0),
            here_map.MapMeasure(here_map.MapMeasureKind.zoomLevel, 18),
            bowFactor,
            Duration(milliseconds: durationMillis));
    state.mapController?.camera.startAnimation(animation);
  }

  void startNavModeCamera() {
    if (!state.isInNavigationMode) {
      state = state.copyWith(isInNavigationMode: true);
    }
  }

  void stopNavModeCamera() {
    if (state.isInNavigationMode) {
      state = state.copyWith(isInNavigationMode: false);
      var geoCoords = here_core.GeoCoordinates(
          state.latestLocation!.latitude!, state.latestLocation!.longitude!);
      flyTo(geoCoordinates: geoCoords, bowFactor: 0, durationMillis: 1000);
    }
  }

  void flyToInNavMode({
    required here_core.GeoCoordinates geoCoordinates,
    int durationMillis = 1000,
    double bowFactor = 0,
  }) {
    here_core.GeoCoordinatesUpdate geoCoordinatesUpdate =
        here_core.GeoCoordinatesUpdate.fromGeoCoordinates(geoCoordinates);
    here_map.MapCameraAnimation animation =
        here_map.MapCameraAnimationFactory.flyToWithOrientationAndZoom(
      geoCoordinatesUpdate,
      here_core.GeoOrientationUpdate(
        state.compass?.headingForCameraMode ?? 0,
        60,
      ),
      here_map.MapMeasure(
        here_map.MapMeasureKind.zoomLevel,
        19,
      ),
      bowFactor,
      Duration(milliseconds: durationMillis),
    );
    state.mapController?.camera.startAnimation(animation);
  }

  void disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    await SDKNativeEngine.sharedInstance?.dispose();
    here_core.SdkContext.release();
  }

  Future<here_map.MapMarker> addMarker(here_core.GeoCoordinates coords,
      {bool shouldFly = false}) async {
    if (_photoMapImage == null) {
      Uint8List imagePixelData =
          await _loadFileAsUint8List('assets/markergb1.png');
      _photoMapImage = here_map.MapImage.withPixelDataAndImageFormat(
          imagePixelData, here_map.ImageFormat.png);
    }
    if (_selectedCoords != null && _selectedMarker != null) {
      state.mapController?.mapScene.removeMapMarker(_selectedMarker!);
      _selectedCoords = null;
      _selectedMarker = null;
    }

    here_map.MapMarker mapMarker = here_map.MapMarker(coords, _photoMapImage!);
    mapMarker.drawOrder = 1;

    state.mapController?.mapScene.addMapMarker(mapMarker);

    _selectedMarker = mapMarker;
    _selectedCoords = coords;

    if (shouldFly) {
      flyTo(geoCoordinates: coords, bowFactor: 0.5, durationMillis: 500);
      state = state.copyWith(shouldFly: false);
    }

    return mapMarker;
  }

  Future<Uint8List> _loadFileAsUint8List(String assetPathToFile) async {
    // The path refers to the assets directory as specified in pubspec.yaml.
    ByteData fileData = await rootBundle.load(assetPathToFile);
    return Uint8List.view(fileData.buffer);
  }

  void loadCustomMapStyle(bool dark) {
    state.mapController?.mapScene.loadSceneFromConfigurationFile(
        "assets/maps/v1-${dark ? "night" : "day"}.json",
        (here_map.MapError? error) {
      if (error == null) {
        darkModeMap = dark;
      } else {
        throw error;
      }
    });
  }
}
