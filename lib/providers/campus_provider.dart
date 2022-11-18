import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:treeroute/models/campus.dart';

class CampusState {
  Campus? campus;
  CampusState({this.campus});
}

class CampusProvider extends StateNotifier<CampusState> {
  Ref ref;
  CampusProvider(this.ref) : super(CampusState());

  void setCampus(Campus campus) {
    state = CampusState(campus: campus);
  }

  void clearCampus() {
    state = CampusState();
  }

  Future<Campus?> getCampus(int id) async {
    var res = await Supabase.instance.client
        .from('campuses')
        .select()
        .eq('id', id)
        .maybeSingle() as Map<String, dynamic>?;
    if (res == null) {
      return null;
    } else {
      return Campus.fromMap(res);
    }
  }

  Future<List<Campus>> getCampuses() async {
    var res = await Supabase.instance.client.from('campuses').select()
        as List<dynamic>;
    return res.map((e) => Campus.fromMap(e)).toList();
  }
}
