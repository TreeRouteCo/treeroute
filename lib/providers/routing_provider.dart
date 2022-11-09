import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart' as here_core;
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart' as here_map;
import 'package:here_sdk/routing.dart' as here_route;
import 'package:here_sdk/search.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';

class RouteState {
  final here_route.RoutingEngine? routingEngine;
  final here_route.Route? routes;
  final List<here_map.MapPolyline>? polylines;
  final List<here_core.GeoCoordinates>? waypoints;
  final here_core.GeoCoordinates? start;
  final here_core.GeoCoordinates? end;
  final Suggestion? destination;

  RouteState({
    this.routingEngine,
    this.routes,
    this.polylines,
    this.waypoints,
    this.start,
    this.end,
    this.destination,
  });

  RouteState copyWith({
    here_route.RoutingEngine? routingEngine,
    here_route.Route? routes,
    List<here_map.MapPolyline>? polylines,
    List<here_core.GeoCoordinates>? waypoints,
    here_core.GeoCoordinates? start,
    here_core.GeoCoordinates? end,
    Suggestion? destination,
  }) {
    return RouteState(
      routingEngine: routingEngine ?? this.routingEngine,
      routes: routes ?? this.routes,
      polylines: polylines ?? this.polylines,
      waypoints: waypoints ?? this.waypoints,
      start: start ?? this.start,
      end: end ?? this.end,
      destination: destination ?? this.destination,
    );
  }

  @override
  String toString() {
    return 'RouteState(routingEngine: $routingEngine, routes: $routes, polylines: $polylines, waypoints: $waypoints, start: $start, end: $end, destination: $destination)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteState &&
        other.routingEngine == routingEngine &&
        other.routes == routes &&
        listEquals(other.polylines, polylines) &&
        listEquals(other.waypoints, waypoints) &&
        other.start == start &&
        other.end == end &&
        other.destination == destination;
  }

  @override
  int get hashCode {
    return routingEngine.hashCode ^
        routes.hashCode ^
        polylines.hashCode ^
        waypoints.hashCode ^
        start.hashCode ^
        end.hashCode ^
        destination.hashCode;
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
        ref.read(locationProvider).compass?.heading;
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
          _zoomToRoute(route);
          //_logRouteViolations(route);
        } else {
          //var error = routingError.toString();
          //_showDialog('Error', 'Error while calculating a route: $error');
        }
      });
    } else {
      state.routingEngine?.calculatePedestrianRoute(
          waypoints, here_route.PedestrianOptions.withDefaults(),
          (routingError, routeList) {
        if (routingError == null) {
          // When error is null, it is guaranteed that the list is not empty.
          var route = routeList!.first;
          _showRouteDetails(route);
          _showRouteOnMap(route);
          _zoomToRoute(route);
          //_logRouteViolations(route);
        } else {
          var error = routingError.toString();
          print('Error while calculating a route: $error');
        }
      });
    }
  }

  void _showRouteDetails(here_route.Route route) {
    int estimatedTravelTimeInSeconds = route.duration.inSeconds;
    int lengthInMeters = route.lengthInMeters;

    String routeDetails =
        'Travel Time: ${_formatTime(estimatedTravelTimeInSeconds)}, Length: ${_formatLength(lengthInMeters)}';

    print('Route Details $routeDetails');
  }

  String _formatLength(int meters) {
    int kilometers = meters ~/ 1000;
    int remainingMeters = meters % 1000;

    return '$kilometers.$remainingMeters km';
  }

  _showRouteOnMap(here_route.Route route) {
    state = state.copyWith(routes: route);
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
    state.polylines?.add(routeMapPolyline);
    state = state;
  }

  _zoomToRoute(here_route.Route route) {
    here_core.GeoBox routeGeoBox = route.boundingBox;
    ref
        .read(locationProvider)
        .mapController
        ?.camera
        .lookAtAreaWithGeoOrientation(
            routeGeoBox, here_core.GeoOrientationUpdate(null, null));
  }

  _removeRoutesFromMap() {
    if (state.polylines != null) {
      for (here_map.MapPolyline mapPolyline in state.polylines!) {
        ref
            .read(locationProvider)
            .mapController
            ?.mapScene
            .removeMapPolyline(mapPolyline);
      }
      state.polylines?.clear();
      state = state;
    }
  }

  String _formatTime(int sec) {
    int hours = sec ~/ 3600;
    int minutes = (sec % 3600) ~/ 60;

    return '$hours:$minutes min';
  }

  RouteState copyWith({
    here_route.RoutingEngine? routingEngine,
    here_route.Route? routes,
    List<here_map.MapPolyline>? polylines,
    List<here_core.GeoCoordinates>? waypoints,
    here_core.GeoCoordinates? start,
    here_core.GeoCoordinates? end,
    Suggestion? destination,
  }) {
    return RouteState(
      routingEngine: routingEngine ?? state.routingEngine,
      routes: routes ?? state.routes,
      polylines: polylines ?? state.polylines,
      waypoints: waypoints ?? state.waypoints,
      start: start ?? state.start,
      end: end ?? state.end,
      destination: destination ?? state.destination,
    );
  }
}
