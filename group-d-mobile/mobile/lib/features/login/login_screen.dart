import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'anna.lopez@hackathon.test');
  final _passCtrl = TextEditingController(text: 'Hackathon2026!');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await ref.read(authNotifierProvider.notifier).signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider).valueOrNull;
    if (state is MiraAuthError) {
      setState(() {
        _error = state.message;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiraTheme.warmBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Text(
                'Ravi de te\nrevoir.',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Connecte-toi pour poursuivre ton parcours.',
                style: TextStyle(color: MiraTheme.charcoal.withOpacity(0.7)),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ton.email@mira.test',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Se connecter'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: MiraTheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Comptes test : voir contracts/test-accounts.md',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
