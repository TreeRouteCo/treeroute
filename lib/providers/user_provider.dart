import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:treeroute/models/user.dart';
import 'package:treeroute/providers/providers.dart';

class UserState {
  final UserAccount? userAccount;
  final bool loading;

  UserState({
    this.userAccount,
    this.loading = false,
  });

  UserState copyWith({
    UserAccount? userAccount,
    bool? loading,
  }) {
    return UserState(
      userAccount: userAccount ?? this.userAccount,
      loading: loading ?? this.loading,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userAccount': userAccount?.toMap(),
      'loading': loading,
    };
  }

  factory UserState.fromMap(Map<String, dynamic> map) {
    return UserState(
      userAccount: map['userAccount'] != null
          ? UserAccount.fromMap(map['userAccount'])
          : null,
      loading: map['loading'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserState.fromJson(String source) =>
      UserState.fromMap(json.decode(source));

  @override
  String toString() =>
      'UserState(userAccount: $userAccount, loading: $loading)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserState &&
        other.userAccount == userAccount &&
        other.loading == loading;
  }

  @override
  int get hashCode => userAccount.hashCode ^ loading.hashCode;
}

class UserProvider extends StateNotifier<UserState> {
  final Ref ref;

  UserProvider(this.ref) : super(UserState());

  void setUser(UserAccount userAccount) {
    state = state.copyWith(userAccount: userAccount);
  }

  void setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void clear() {
    state = UserState();
  }

  Future<UserAccount?> getUser({String? id}) async {
    setLoading(true);
    if (id == null) {
      final authState = ref.read(authProvider);
      if (authState.session == null) {
        setLoading(false);
        return null;
      } else {
        final user = authState.session!.user;
        final editableProfile = await Supabase.instance.client
            .from('users')
            .select()
            .eq('uid', user.id)
            .maybeSingle() as Map<String, dynamic>?;
        final privatePorfile = await Supabase.instance.client
            .from('users_private')
            .select()
            .eq('uid', user.id)
            .maybeSingle() as Map<String, dynamic>?;
        if (editableProfile != null) {
          state = state.copyWith(
              userAccount: UserAccount(
                user: user,
                firstName: editableProfile['first_name'] as String?,
                lastName: editableProfile['last_name'] as String?,
                username: editableProfile['username'] as String?,
                verified: privatePorfile?['verified'] as bool? ?? false,
                modCampuses: (privatePorfile?['mod_campuses'] as List<dynamic>?)
                        ?.map((e) => e as int)
                        .toList() ??
                    [],
                admin: privatePorfile?['admin'] as bool? ?? false,
                elevationDescription: privatePorfile?['description'] as String?,
                bio: editableProfile['bio'] as String?,
              ),
              loading: false);
          return state.userAccount;
        }
      }
    } else {
      final editableProfile = await Supabase.instance.client
          .from('users')
          .select()
          .eq('uid', id)
          .maybeSingle() as Map<String, dynamic>?;
      final privatePorfile = await Supabase.instance.client
          .from('users_private')
          .select()
          .eq('uid', id)
          .maybeSingle() as Map<String, dynamic>?;
      if (editableProfile != null) {
        setLoading(false);
        return UserAccount(
          firstName: editableProfile['first_name'] as String?,
          lastName: editableProfile['last_name'] as String?,
          username: editableProfile['username'] as String?,
          verified: privatePorfile?['verified'] as bool? ?? false,
          modCampuses: (privatePorfile?['mod_campuses'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList() ??
              [],
          admin: privatePorfile?['admin'] as bool? ?? false,
          elevationDescription: privatePorfile?['description'] as String?,
          bio: editableProfile['bio'] as String?,
        );
      }
    }

    setLoading(false);

    return null;
  }

  Future<UserAccount?> updateUser(UserAccount userAccount,
      {String? uid}) async {
    setLoading(true);
    final authState = ref.read(authProvider);
    Map<String, dynamic>? newUser;
    if (authState.session == null) {
      setLoading(false);
      return null;
    } else {
      uid ??= authState.session!.user.id;

        // This is also enforced on the backend. For my feelow applied 
        // cybersec members, of course.
      if (uid != authState.session!.user.id &&
          (state.userAccount?.admin ?? false)) {
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

      if (newUser != null && uid != authState.session!.user.id) {
        state = state.copyWith(
            userAccount: UserAccount(
              user: state.userAccount!.user,
              firstName: newUser['first_name'] as String?,
              lastName: newUser['last_name'] as String?,
              username: newUser['username'] as String?,
              bio: newUser['bio'] as String?,
            ),
            loading: false);
        return state.userAccount;
      }

      setLoading(false);
      return UserAccount(
        user: state.userAccount!.user,
        firstName: newUser?['first_name'] as String?,
        lastName: newUser?['last_name'] as String?,
        username: newUser?['username'] as String?,
        bio: newUser?['bio'] as String?,
      );
    }
  }
}
