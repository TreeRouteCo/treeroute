import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:treeroute/models/user.dart';
import 'package:treeroute/providers/providers.dart';

class UserState {
  final Profile? profile;
  final User? user;
  final bool loading;

  UserState({
    this.profile,
    this.user,
    this.loading = false,
  });

  UserState copyWith({
    Profile? profile,
    User? user,
    bool? loading,
  }) {
    return UserState(
      profile: profile ?? this.profile,
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': profile?.toMap(),
      'user': user?.toJson(),
      'loading': loading,
    };
  }

  factory UserState.fromMap(Map<String, dynamic> map) {
    return UserState(
      profile: map['profile'] != null ? Profile.fromMap(map['profile']) : null,
      user: map['user'] != null ? User.fromJson(map['user']) : null,
      loading: map['loading'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserState.fromJson(String source) =>
      UserState.fromMap(json.decode(source));

  @override
  String toString() =>
      'UserState(profile: $profile, user: $user, loading: $loading)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserState &&
        other.profile == profile &&
        other.user == user &&
        other.loading == loading;
  }

  @override
  int get hashCode => profile.hashCode ^ user.hashCode ^ loading.hashCode;
}

class UserProvider extends StateNotifier<UserState> {
  final Ref ref;

  UserProvider(this.ref) : super(UserState());

  void setProfile(Profile profile) {
    state = state.copyWith(profile: profile);
  }

  void setUser(User user) {
    state = state.copyWith(user: user);
  }

  void setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void clear() {
    state = UserState();
  }

  Future<Profile?> getProfile({String? id}) async {
    setLoading(true);
    final loggedInId = ref.read(authProvider).session?.user.id;

    if (id == null) {
      if (id == loggedInId) {
        setLoading(false);
        throw "No session or ID found";
      }
      id = loggedInId;
    }

    var response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('uid', id)
        .maybeSingle() as Map<String, dynamic>?;

    final userAttributesResponse = await Supabase.instance.client
        .from('users_private')
        .select()
        .eq('uid', id)
        .maybeSingle() as Map<String, dynamic>?;

    if (response == null || userAttributesResponse == null) {
      setLoading(false);
      return null;
    } else {
      final profile = Profile.fromMap({
        ...response,
        ...userAttributesResponse,
      });
      if (loggedInId == id) {
        setProfile(profile);
      }
      setLoading(false);
      return profile;
    }
  }

  Future<Profile?> updateProfile(Profile userAccount, {String? uid}) async {
    setLoading(true);
    final authState = ref.read(authProvider);
    Map<String, dynamic>? newUser;
    Profile? newProfile;
    if (authState.session == null) {
      setLoading(false);
      throw "Must be logged in to update profiles";
    } else {
      uid ??= state.user?.id;
      if (uid == null) {
        setLoading(false);
        throw "No session or ID found";
      }

      // This is also enforced on the backend. (Good try tho <3).
      if (uid != authState.session!.user.id &&
          (state.profile?.admin ?? false)) {
        setLoading(false);
        throw "User is not authorized to update this user's profile";
      }

      newUser = await Supabase.instance.client
          .from('users')
          .upsert({
            'first_name': userAccount.firstName,
            'last_name': userAccount.lastName,
            'username': userAccount.username,
            'bio': userAccount.bio,
          })
          .eq('uid', uid)
          .single() as Map<String, dynamic>?;

      if (newUser != null) newProfile = Profile.fromMap(newUser);

      if (newProfile != null && uid != state.user?.id) {
        setProfile(newProfile);
      }

      setLoading(false);
      return newUser != null ? Profile.fromMap(newUser) : null;
    }
  }
}
