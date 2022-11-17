import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  var loading = false;
  var error = false;
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

    final _formKey = GlobalKey<FormState>();

    try {
      if (userState.user?.id == widget.uidToEdit) {
        profile = userState.profile;
        //loading = false;
      } else if (userState.user?.id != widget.uidToEdit) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          profile = await userProv.getProfile(id: widget.uidToEdit);
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
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () {
                Beamer.of(context).beamBack();
              },
            ),
            title: const Text('Edit Profile'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.check_rounded),
                onPressed: () {},
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
                : loading
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 100,
                          ),
                          Text(
                            'Loading Profile...',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          const SizedBox(height: 50),
                          const CircularProgressIndicator(),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 150,
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
                                          ),
                                          TextFormField(
                                            controller: lastNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Last Name',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) {
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
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                focusNode: usernameFocusNode,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(bioFocusNode);
                                },
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
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your bio';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.newline,
                                focusNode: bioFocusNode,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                              VerticalDivider(),
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

class ScrollOrFitBottom extends StatelessWidget {
  final Widget scrollableContent;
  final Widget bottomContent;

  ScrollOrFitBottom({
    required this.scrollableContent,
    required this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: <Widget>[
              Expanded(child: scrollableContent),
              bottomContent
            ],
          ),
        ),
      ],
    );
  }
}
