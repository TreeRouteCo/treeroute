import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/models/campus.dart';
import 'package:treeroute/models/user.dart';

import '../providers/providers.dart';

class EditProfilePage extends StatefulHookConsumerWidget {
  final String uidToEdit;

  const EditProfilePage({super.key, required this.uidToEdit});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  Profile? profile;
  Profile? originalProfile;
  List<Campus> campuses = [];
  var loading = true;
  var updating = false;
  var error = false;
  static final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userState = ref.read(userProvider);
    final userProv = ref.read(userProvider.notifier);

    // Form fields
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final usernameController = useTextEditingController();
    final bioController = useTextEditingController();

    // Focus nodes
    final firstNameFocusNode = useFocusNode();
    final lastNameFocusNode = useFocusNode();
    final usernameFocusNode = useFocusNode();
    final bioFocusNode = useFocusNode();

    if (campuses.isEmpty) {
      ref.read(campusProvider.notifier).getCampuses().then((value) {
        setState(() {
          campuses = value;
        });
      });
    }

    try {
      if (userState.user?.id == widget.uidToEdit && profile == null) {
        profile = userState.profile ?? Profile(campusId: 1);
        originalProfile = profile?.copyWith();
        loading = false;
        setState(() {});
      } else if (userState.user?.id != widget.uidToEdit && profile == null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          profile ??= await userProv.getProfile(id: widget.uidToEdit);
          originalProfile = profile?.copyWith();
          loading = false;
          setState(() {});
        });
      }
    } catch (e) {
      error = true;
    }

    if (!loading && profile != null) {
      firstNameController.text = profile!.firstName ?? "";
      lastNameController.text = profile!.lastName ?? "";
      usernameController.text = profile!.username ?? "";
      bioController.text = profile!.bio ?? "";
    }

    return Material(
      // Sliver app bar large
      color: Theme.of(context).cardColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: updating || userState.profile == null
                  ? null
                  : () {
                      Beamer.of(context).beamBack();
                    },
            ),
            title: const Text('Edit Profile'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.check_rounded),
                onPressed: (updating || loading)
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            updating = true;
                          });
                          if (profile != originalProfile) {
                            try {
                              await userProv.updateProfile(
                                profile!,
                                uid: widget.uidToEdit,
                              );
                              if (userState.user?.id == widget.uidToEdit) {
                                await userProv.getProfile();
                              }
                            } catch (e) {
                              print(e);
                              error = true;
                            }
                          }

                          setState(() {
                            updating = false;
                          });

                          if (mounted && !error) {
                            Beamer.of(context).beamBack();
                          }
                        }
                      },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: error
                ? Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Text(
                        'There was an issue loading this profile...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            profile = null;
                            loading = true;
                            error = false;
                          });
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  )
                : loading || updating
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 100,
                          ),
                          Text(
                            loading
                                ? 'Loading Profile...'
                                : 'Updating Profile...',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          const SizedBox(height: 50),
                          const CircularProgressIndicator(),
                        ],
                      )
                    : Container(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 180,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.account_circle_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          size: 150,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextFormField(
                                            controller: firstNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'First Name',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) {
                                              value = value?.trim();
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your first name';
                                              }
                                              return null;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            focusNode: firstNameFocusNode,
                                            onFieldSubmitted: (value) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      lastNameFocusNode);
                                            },
                                            onChanged: (value) {
                                              profile!.firstName = value;
                                            },
                                          ),
                                          TextFormField(
                                            controller: lastNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Last Name',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) {
                                              value = value?.trim();
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your last name';
                                              }
                                              return null;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            focusNode: lastNameFocusNode,
                                            onFieldSubmitted: (value) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      usernameFocusNode);
                                            },
                                            onChanged: (value) {
                                              profile!.lastName = value;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  value = value?.trim();
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }

                                  if (value.length > 20) {
                                    return 'Username must be less than 20 characters';
                                  } else if (value.length < 3) {
                                    return 'Username must be at least 3 characters';
                                  }
                                },
                                textInputAction: TextInputAction.next,
                                focusNode: usernameFocusNode,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(bioFocusNode);
                                },
                                onChanged: (value) {
                                  profile!.username = value;
                                },
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Hint: if you don't want to be searchable don't set a username!",
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: bioController,
                                // Multiline text field
                                maxLines: 10,
                                minLines: 7,
                                decoration: const InputDecoration(
                                  labelText: 'Bio',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  value = value?.trim();
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }

                                  if (value.length > 200) {
                                    return 'Bio must be less than 200 characters';
                                  }
                                },
                                textInputAction: TextInputAction.newline,
                                focusNode: bioFocusNode,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).unfocus();
                                },
                                onChanged: (value) {
                                  profile!.bio = value;
                                },
                              ),
                              const SizedBox(height: 20),
                              const VerticalDivider(),
                              const SizedBox(height: 20),
                              Text(
                                "Campus Selection",
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              const SizedBox(height: 20),
                              if (campuses.length > 1)
                                DropdownButtonFormField<int>(
                                  value: profile?.campusId ?? 1,
                                  decoration: const InputDecoration(
                                    labelText: 'Campus',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: campuses.map<DropdownMenuItem<int>>(
                                      (Campus value) {
                                    return DropdownMenuItem<int>(
                                      value: value.id,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      profile?.campusId = newValue;
                                    });
                                  },
                                ),
                              if (userState.profile?.admin ?? false) ...[
                                const SizedBox(height: 20),
                                const VerticalDivider(),
                                const SizedBox(height: 20),
                                Text(
                                  "Admin Settings",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                const SizedBox(height: 20),
                                const Text("Coming Soon")
                              ]
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
