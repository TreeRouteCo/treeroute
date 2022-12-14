import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart' as here_core;
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart' as here_map;
import 'package:here_sdk/routing.dart' as here_route;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';

import '../models/place.dart';

class RouteState {
  final here_route.RoutingEngine? routingEngine;
  final here_route.Route? route;
  final here_map.MapPolyline? polyline;
  final List<here_route.Waypoint>? waypoints;
  final here_core.GeoCoordinates? start;
  final here_core.GeoCoordinates? end;
  final Place? destination;
  final int? durationInSecs;
  final int? distanceInMeters;

  RouteState({
    this.routingEngine,
    this.route,
    this.polyline,
    this.waypoints,
    this.start,
    this.end,
    this.destination,
    this.durationInSecs,
    this.distanceInMeters,
  });

  RouteState copyWith({
    here_route.RoutingEngine? routingEngine,
    here_route.Route? route,
    here_map.MapPolyline? polyline,
    List<here_route.Waypoint>? waypoints,
    here_core.GeoCoordinates? start,
    here_core.GeoCoordinates? end,
    Place? destination,
    int? durationInSecs,
    int? distanceInMeters,
  }) {
    return RouteState(
      routingEngine: routingEngine ?? this.routingEngine,
      route: route ?? this.route,
      polyline: polyline ?? this.polyline,
      waypoints: waypoints ?? this.waypoints,
      start: start ?? this.start,
      end: end ?? this.end,
      destination: destination ?? this.destination,
      durationInSecs: durationInSecs ?? this.durationInSecs,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    );
  }

  @override
  String toString() {
    return 'RouteState(routingEngine: $routingEngine, route: $route, polyline: $polyline, waypoints: $waypoints, start: $start, end: $end, destination: $destination, durationInSecs: $durationInSecs, distanceInMeters: $distanceInMeters)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteState &&
        other.routingEngine == routingEngine &&
        other.route == route &&
        other.polyline == polyline &&
        listEquals(other.waypoints, waypoints) &&
        other.start == start &&
        other.end == end &&
        other.destination == destination &&
        other.durationInSecs == durationInSecs &&
        other.distanceInMeters == distanceInMeters;
  }

  @override
  int get hashCode {
    return routingEngine.hashCode ^
        route.hashCode ^
        polyline.hashCode ^
        waypoints.hashCode ^
        start.hashCode ^
        end.hashCode ^
        destination.hashCode ^
        durationInSecs.hashCode ^
        distanceInMeters.hashCode;
  }

  removePolyline() {
    return RouteState(
      routingEngine: routingEngine,
      route: route,
      polyline: null,
      waypoints: waypoints,
      start: start,
      end: end,
      destination: destination,
      durationInSecs: durationInSecs,
      distanceInMeters: distanceInMeters,
    );
  }
}

class RoutingProvider extends StateNotifier<RouteState> {
  Ref ref;
  RoutingProvider(this.ref)
      : super(RouteState(
          routingEngine: here_route.RoutingEngine(),
        ));

  void initRoutingEngine() {
    try {
      final routingEngine = here_route.RoutingEngine();
      state = state.copyWith(routingEngine: routingEngine);
    } on InstantiationException {
      throw ("Initialization of RoutingEngine failed.");
    }
  }

  Future<void> addRoute({
    here_core.GeoCoordinates? beginCoords,
    required here_core.GeoCoordinates endCoords,
    bool isBiking = true,
  }) async {
    _removeRoutesFromMap();
    var startGeoCoordinates = beginCoords ??
        here_core.GeoCoordinates(
          ref.read(locationProvider).latestLocation?.latitude ?? 0,
          ref.read(locationProvider).latestLocation?.longitude ?? 0,
        );
    var destinationGeoCoordinates = endCoords;
    var startWaypoint = here_route.Waypoint.withDefaults(startGeoCoordinates);
    startWaypoint.headingInDegrees =
        ref.read(locationProvider).compass?.headingForCameraMode;
    var destinationWaypoint =
        here_route.Waypoint.withDefaults(destinationGeoCoordinates);

    List<here_route.Waypoint> waypoints = [startWaypoint, destinationWaypoint];

    if (isBiking) {
      state.routingEngine?.calculateBicycleRoute(
          waypoints, here_route.BicycleOptions(), (routingError, routeList) {
        if (routingError == null) {
          // When error is null, it is guaranteed that the list is not empty.
          var route = routeList!.first;
          _showRouteDetails(route);
          _showRouteOnMap(route);
          //_zoomToRoute(route);
          //_logRouteViolations(route);
        }
      });
    } else {
      state.routingEngine?.calculatePedestrianRoute(
          waypoints, here_route.PedestrianOptions.withDefaults(),
          (routingError, routeList) {
        if (routingError == null) {
          // When error is null, it is guaranteed that the list is not empty.
          var route = routeList!.first;
          state = state.copyWith(
            route: route,
            waypoints: waypoints,
            start: startGeoCoordinates,
            end: destinationGeoCoordinates,
            polyline: here_map.MapPolyline(
              route.geometry,
              20,
              Colors.green,
            ),
            destination: ref.read(placeProvider).selectedPlace!,
            distanceInMeters: route.lengthInMeters,
            durationInSecs: route.duration.inSeconds,
          );
          _showRouteDetails(route);
          _showRouteOnMap(route);
          //_zoomToRoute(route);
          //_logRouteViolations(route);
        }
      });
    }
  }

  List<String> _showRouteDetails(here_route.Route route) {
    int estimatedTravelTimeInSeconds = route.duration.inSeconds;
    int lengthInMeters = route.lengthInMeters;

    return [
      formatTime(estimatedTravelTimeInSeconds),
      formatLength(lengthInMeters)
    ];
  }

  String formatLength(int meters) {
    int kilometers = meters ~/ 1000;
    int remainingMeters = meters % 1000;

    return '$kilometers.$remainingMeters km';
  }

  _showRouteOnMap(here_route.Route route) {
    // Show route as polyline.
    here_core.GeoPolyline routeGeoPolyline = route.geometry;
    double widthInPixels = 20;
    here_map.MapPolyline routeMapPolyline =
        here_map.MapPolyline(routeGeoPolyline, widthInPixels, Colors.green);
    ref
        .read(locationProvider)
        .mapController
        ?.mapScene
        .addMapPolyline(routeMapPolyline);
    ref.read(locationProvider.notifier).shouldFly(doNow: true);
    state = state.copyWith(polyline: routeMapPolyline);
  }

  zoomToRoute(here_route.Route route) {
    here_core.GeoBox routeGeoBox = route.boundingBox;
    ref
        .read(locationProvider)
        .mapController
        ?.camera
        .lookAtAreaWithGeoOrientation(
            routeGeoBox, here_core.GeoOrientationUpdate(null, null));
  }

  _removeRoutesFromMap() {
    if (state.polyline != null) {
      ref
          .read(locationProvider)
          .mapController
          ?.mapScene
          .removeMapPolyline(state.polyline!);
      state = state.removePolyline();
    }
  }

  String formatTime(int sec) {
    int hours = sec ~/ 3600;
    int minutes = (sec % 3600) ~/ 60;

    return '$hours:$minutes min';
  }

  void clearRoutes() {
    _removeRoutesFromMap();
    ref.read(locationProvider.notifier).stopNavModeCamera();
    state = RouteState(
      routingEngine: state.routingEngine,
    );
  }

  RouteState copyWith({
    here_route.RoutingEngine? routingEngine,
    here_route.Route? route,
    here_map.MapPolyline? polyline,
    List<here_route.Waypoint>? waypoints,
    here_core.GeoCoordinates? start,
    here_core.GeoCoordinates? end,
    Place? destination,
  }) {
    return RouteState(
      routingEngine: routingEngine ?? state.routingEngine,
      route: route ?? state.route,
      polyline: polyline ?? state.polyline,
      waypoints: waypoints ?? state.waypoints,
      start: start ?? state.start,
      end: end ?? state.end,
      destination: destination ?? state.destination,
    );
  }
}
