// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

void main(List<String> args) async {
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

    if (addressIndex == -1 && rooms.isNotEmpty) {
      aka = rooms.cast();
      rooms = [];
    }
    if (aka.length == 1) {
      aka.add("Unknown Name");
    }

    treeRouteLocs.add(TreeRouteObj(
      geoloc: {
        "lat": loc["lat"],
        "lon": loc["lon"],
      },
      slug: aka[0],
      aka: aka,
      name: aka[1],
      rooms: rooms,
      address: address ?? "Unknown Street",
    ));
  }

  print("Done! Writing to file...");

  // Open file
  final treeRuoteFile = File('treeRouteReady.json');
  final treeRouteWritableFile =
      await treeRuoteFile.open(mode: FileMode.writeOnly);
  treeRouteWritableFile.writeStringSync(
      jsonEncode(treeRouteLocs.map((e) => e.toMap()).toList()));
  treeRouteWritableFile.closeSync();

  print("Complete, written to ${treeRuoteFile.path}");

  // Check if upload arg and key are provided

  if (args.length < 2 || args[0] != "upload") {
    print("Skipping upload, no arg or key provided");
    return;
  }

  print("Uploading to Supabase...");

  final supabase = SupabaseClient(
    'https://zpynevawzefrxhnbuump.supabase.co',
    args[1],
  );

  const table = 'tree_map_upload';

  print("Uploading ${treeRouteLocs.length} locations to $table...");

  await supabase
      .from(table)
      .insert(treeRouteLocs.map((e) => e.toMap()).toList());
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
    this.state = "CA",
    this.country = "US",
    this.aka,
    this.campus = 1,
    required this.slug,
    required this.geoloc,
    this.type,
    this.postalCode = 94305,
    this.departments,
    this.rooms,
  });

  TreeRouteObj copyWith({
    String? name,
    String? address,
    String? state,
    String? country,
    List<String>? aka,
    int? campus,
    String? slug,
    Map<String, double>? geoloc,
    List<String>? type,
    int? postalCode,
    List<String>? departments,
    List<String>? rooms,
  }) {
    return TreeRouteObj(
      name: name ?? this.name,
      address: address ?? this.address,
      state: state ?? this.state,
      country: country ?? this.country,
      aka: aka ?? this.aka,
      campus: campus ?? this.campus,
      slug: slug ?? this.slug,
      geoloc: geoloc ?? this.geoloc,
      type: type ?? this.type,
      postalCode: postalCode ?? this.postalCode,
      departments: departments ?? this.departments,
      rooms: rooms ?? this.rooms,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'state': state,
      'country': country,
      'aka': aka,
      'campus': campus,
      'slug': slug,
      'geoloc': geoloc,
      'type': type,
      'postal_code': postalCode,
      'departments': departments,
      'rooms': rooms,
    };
  }

  factory TreeRouteObj.fromMap(Map<String, dynamic> map) {
    return TreeRouteObj(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      aka: List<String>.from(map['aka']),
      campus: map['campus']?.toInt() ?? 0,
      slug: map['slug'] ?? '',
      geoloc: Map<String, double>.from(map['geoloc']),
      type: List<String>.from(map['type']),
      postalCode: map['postalCode']?.toInt() ?? 0,
      departments: List<String>.from(map['departments']),
      rooms: List<String>.from(map['rooms']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TreeRouteObj.fromJson(String source) =>
      TreeRouteObj.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TreeRouteObj(name: $name, address: $address, state: $state, country: $country, aka: $aka, campus: $campus, slug: $slug, geoloc: $geoloc, type: $type, postalCode: $postalCode, departments: $departments, rooms: $rooms)';
  }

  @override
  int get hashCode {
    return name.hashCode ^
        address.hashCode ^
        state.hashCode ^
        country.hashCode ^
        aka.hashCode ^
        campus.hashCode ^
        slug.hashCode ^
        geoloc.hashCode ^
        type.hashCode ^
        postalCode.hashCode ^
        departments.hashCode ^
        rooms.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return super == other;
  }
}
