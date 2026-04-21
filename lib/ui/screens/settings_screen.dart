import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/precision_panel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kSpace5),
        children: [
          Text(
            'Defaults',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: kSpace4),
          const PrecisionPanel(),
          const SizedBox(height: kSpace8),
          const Divider(),
          const SizedBox(height: kSpace8),
          Center(
            child: Text(
              'NumeriX v1.0.0\nAdvanced Numerical Methods Calculator\n\nBuilt with Flutter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kTextMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
