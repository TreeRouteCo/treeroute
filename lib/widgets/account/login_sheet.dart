import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';
import 'package:treeroute/widgets/common/snackbar.dart';

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

    if (authState.isMagicLinkSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.maybeOf(context)?.pop();
        if (mounted) {
          successSnackbar(
            context,
            "Check your email to log in",
            const Icon(Icons.auto_awesome, color: Colors.white),
          );
          authProv.setInitial();
        }
      });
    }

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
              enabled: !authState.isLoading,
              onSubmitted: (value) {
                if (value != "") {
                  authProv.sendMagicLink(value);
                }
              },
            ),
            if (authState.error != null) ...[
              const SizedBox(height: 20),
              Text(
                authState.error!,
                style: Theme.of(context).textTheme.caption?.copyWith(
                      color: Theme.of(context).errorColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20),
            // Login Button
            if (!authState.isLoading && !authState.isMagicLinkSent)
              OutlinedButton.icon(
                onPressed: () {
                  if (emailText.text != "") {
                    authProv.sendMagicLink(emailText.text);
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              ),
            if (authState.isLoading)
              // Same spacing as the button
              const SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
