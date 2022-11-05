import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TreeRoute',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'TreeRoute - A (better) Stanford Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MapBoxNavigationViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MapBoxNavigationView(
        onCreated: (controller) {
          _controller = controller;
        },
        options: MapBoxOptions(
          // Stanford Main Quad Latitute and Longitude
          initialLatitude: 37.42796133580664,
          initialLongitude: -122.16945096118164,
          zoom: 15.0,
          tilt: 60.0,
          bearing: 0.0,
          enableRefresh: true,
          alternatives: true,
          voiceInstructionsEnabled: true,
          bannerInstructionsEnabled: true,
          allowsUTurnAtWayPoints: true,
          mode: MapBoxNavigationMode.walking,
          simulateRoute: true,
          language: "en",
          units: VoiceUnits.imperial,
          //onRouteEvent: (event) => print(event),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //await _controller?.clearRoute();
          // From my location to Stanford Main Quad
          var waypoints = [
            //Branner Dining Hall
            WayPoint(
              name: "Florence Moore Dining Hall",
              latitude: 37.422361,
              longitude: -122.172113,
            ),

            WayPoint(
                name: "Stanford Main Quad",
                latitude: 37.42796133580664,
                longitude: -122.16945096118164)
          ];
          await _controller?.buildRoute(wayPoints: waypoints);
          await _controller?.startNavigation(
              options: MapBoxOptions(
            initialLatitude: 37.42796133580664,
            initialLongitude: -122.16945096118164,
            zoom: 15.0,
            tilt: 60.0,
            bearing: 0.0,
            enableRefresh: true,
            alternatives: true,
            voiceInstructionsEnabled: true,
            bannerInstructionsEnabled: true,
            allowsUTurnAtWayPoints: true,
            mode: MapBoxNavigationMode.walking,
            simulateRoute: true,
            language: "en",
            units: VoiceUnits.imperial,
          ));
        },
        tooltip: 'Start Navigation',
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
