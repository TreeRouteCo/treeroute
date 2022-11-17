import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/models/user.dart';

class EditProfilePage extends StatefulHookConsumerWidget {
  final int uidToEdit;

  const EditProfilePage({super.key, required this.uidToEdit});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      // Sliver app bar large
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            leading: IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  Beamer.of(context).beamBack();
                }),
            title: const Text('Edit Profile'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.check_rounded),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 1000,
            ),
          ),
        ],
      ),
    );
  }
}
