// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  var compressedLocs = [];
  var sourceFile = File("source.json");
  var treeMapLocs = jsonDecode(
    await sourceFile.openRead().transform(utf8.decoder).join(""),
  );

  for (var loc in treeMapLocs) {
    // Find places where latitude and longitude are the same in different locations
    if (compressedLocs
        .any((l) => l["lat"] == loc["lat"] && l["lon"] == loc["lon"])) {
      continue;
    }
    var sameLocs = treeMapLocs
        .where((l) => l["lat"] == loc["lat"] && l["lon"] == loc["lon"]);
    // Add them to the compressed list
    compressedLocs.add({
      "lat": loc["lat"],
      "lon": loc["lon"],
      "names": sameLocs.map((l) => l["name"]).toList()
    });
    // Remove them from the original list
  }
  print(
    "Reduced to ${compressedLocs.length} from ${treeMapLocs.length} locations! \n"
    "Writing to file...",
  );
  // Open file
  final file = File('processed.json');
  final writableFile = await file.open(mode: FileMode.writeOnly);
  writableFile.writeStringSync(jsonEncode(compressedLocs));
  writableFile.closeSync();

  /////////////////////

  print("Complete, written to ${file.path}\n"
      "Converting to TreeRoute structure "
      "(This will try to guess streets, nicks and main names)");

  /////////////////////
}

class TreeRouteObj {
  String name;
  String address;
  String state;
  String country;
  List<String>? aka;
  int campus;
  String slug;
  Map<String, double> geoloc;
  List<String>? type;
  int postalCode;
  List<String>? departments;
  List<String>? rooms;

  TreeRouteObj({
    required this.name,
    required this.address,
    this.aka,
    this.campus = 1,
    this.country = "US",
    required this.geoloc,
    this.postalCode = 94305,
    this.departments,
    this.rooms,
    required this.slug,
    this.state = "CA",
    this.type,
  });
}
