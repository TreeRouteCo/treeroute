import 'dart:async';
import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:here_sdk/core.dart' as here_core;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.threading.dart';
import 'package:here_sdk/mapview.dart' as here_map;
import 'package:here_sdk/search.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';

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
    );
  }

  @override
  String toString() {
    return 'LocationState(isLocating: $isLocating, permissionState: $permissionState, mapController: $mapController, latestLocation: $latestLocation, locator: $locator, shouldFly: $shouldFly, lastLines: $lastLines, compass: $compass)';
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
        ));
  final Ref ref;
  here_map.LocationIndicator? _locIndicator;
  bool? darkModeMap;

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
      loc.bearingInDegrees = state.compass?.heading ?? 0;

      _locIndicator?.updateLocation(loc);

      if (state.shouldFly) {
        _flyTo(geoCoordinates: nextCoordinate);
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
      state.copyWith(latestLocation: currentLocation, isLocating: true);
      _updateMap(currentLocation);
    });
  }

  void _flyTo({
    required here_core.GeoCoordinates geoCoordinates,
    int durationMillis = 200,
    double bowFactor = 0,
  }) {
    here_core.GeoCoordinatesUpdate geoCoordinatesUpdate =
        here_core.GeoCoordinatesUpdate.fromGeoCoordinates(geoCoordinates);
    here_map.MapCameraAnimation animation =
        here_map.MapCameraAnimationFactory.flyToWithZoom(
            geoCoordinatesUpdate,
            here_map.MapMeasure(here_map.MapMeasureKind.zoomLevel, 18),
            bowFactor,
            Duration(milliseconds: durationMillis));
    state.mapController?.camera.startAnimation(animation);
  }

  void disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    await SDKNativeEngine.sharedInstance?.dispose();
    here_core.SdkContext.release();
  }

  TaskHandle searchSuggestions(
    String text,
    void Function(SearchError? error, List<Suggestion>? suggestions) callback,
  ) {
    here_core.GeoCoordinates centerGeoCoordinates = here_core.GeoCoordinates(
      state.latestLocation?.latitude ?? 0,
      state.latestLocation?.longitude ?? 0,
    );

    SearchOptions searchOptions = SearchOptions.withDefaults();
    searchOptions.languageCode = here_core.LanguageCode.enUs;
    searchOptions.maxItems = 5;

    TextQueryArea queryArea = TextQueryArea.withCenter(centerGeoCoordinates);

    return state.searchEngine
        .suggest(TextQuery.withArea(text, queryArea), searchOptions, callback);
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
