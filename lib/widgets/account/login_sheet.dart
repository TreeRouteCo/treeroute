import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';

class LoginSheet extends StatefulHookConsumerWidget {
  const LoginSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginSheetState();
}

class _LoginSheetState extends ConsumerState<LoginSheet> {
  @override
  Widget build(BuildContext context) {
    var authProv = ref.read(authProvider.notifier);
    var authState = ref.watch(authProvider);

    var emailText = useTextEditingController();

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: emailText,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              onSubmitted: (value) {
                authProv.sendMagicLink(emailText.text);
              },
            ),
            const SizedBox(height: 20),
            // Login Button
            OutlinedButton.icon(
              onPressed: () {
                authProv.sendMagicLink(emailText.text);
              },
              icon: const Icon(Icons.login),
              label: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
