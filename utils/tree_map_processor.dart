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

  List<TreeRouteObj> treeRouteLocs = [];

  // Get every location, and try to guess the street, nick and main name
  // the first name is an aka, them rooms until the street, then more akas

  for (var loc in compressedLocs) {
    var names = loc["names"];
    String? address;
    var addressIndex = -1;
    List<String> aka = [];
    List<String> rooms = [];

    var i = 0;

    print("========= ${names[0]} =========");

    for (String name in names) {
      print("Processing: $name");
      if (i == 0) {
        print(" - Building ID");
        aka.add(name);
      } else {
        if (mayBeStreet(name) && addressIndex == -1) {
          print(" - Street");
          address = name;
          addressIndex = i;
        } else if (addressIndex == -1) {
          print(" - Room");
          rooms.add(name);
        } else {
          aka.add(name);
          print(" - AKA");
        }
      }

      i++;
    }

    print("-------------------------------");

    treeRouteLocs.add(TreeRouteObj(
      geoloc: {
        "lat": loc["lat"],
        "lon": loc["lon"],
      },
      slug: address == null ? rooms[0] : aka[0],
      aka: address == null ? rooms : aka,
      name: address == null ? rooms[1] : aka[1],
      rooms: address == null ? null : rooms,
      address: address ?? "Unknown Street",
    ));
  }

  print("Done!");

  // Open file
  final treeRuoteFile = File('treeRouteReady.json');
  final treeRouteWritableFile =
      await treeRuoteFile.open(mode: FileMode.writeOnly);
  treeRouteWritableFile.writeStringSync(jsonEncode(treeRouteLocs));
  treeRouteWritableFile.closeSync();

  print("Complete, written to ${treeRuoteFile.path}");
}

bool mayBeStreet(String name) {
  for (var suffix in streetSuffixes) {
    if (name.contains(suffix)) {
      // Check if it starts with a number and ends with a letter or number
      if (RegExp(r"^\d+[a-zA-Z0-9]$").hasMatch(name)) {
        return true;
      }
      print("[WARN] $name -- Unsure if street");
      // check if it has a number in it
      if (RegExp(r"\d").hasMatch(name)) {
        return true;
      }
      return false;
    }
  }
  return false;
}

const streetSuffixes = [
  "st",
  "street",
  "dr",
  "drive",
  "via",
  "way",
  "blvd",
  "boulevard",
  "ave",
  "avenue",
  "rd",
  "road",
  "lane",
  "ln",
  "cir",
  "circle",
  "pl",
  "place",
  "ter",
  "terrace",
  "ct",
  "court",
  "parkway",
  "pkwy",
  "pky",
  "park",
  "mall",
  "highway",
  "hwy",
  "freeway",
  "fwy",
  "expressway",
  "expy",
  "exp",
  "extension",
  "siding",
  "bldg"
];

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
