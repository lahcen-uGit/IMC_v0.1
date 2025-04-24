import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../locale_notifier.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Méthode pour inscrire un nouvel utilisateur
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // Rediriger vers la page d'accueil après l'inscription
        context.go('/'); // Remplace avec la route de ta page d'accueil
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fonction pour obtenir les messages d'erreur selon le code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return AppLocalizations.of(context)!.emailAlreadyUsed;
      case 'invalid-email':
        return AppLocalizations.of(context)!.invalidEmail;
      case 'weak-password':
        return AppLocalizations.of(context)!.weakPassword;
      default:
        return AppLocalizations.of(context)!.signupError;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.createAccount),
        centerTitle: true,
        actions: [
          // Menu pour changer la langue
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              context.read<LocaleNotifier>().setLocale(locale); // Modifier la langue via le Provider
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: Locale('en'), child: Text('English')),
              const PopupMenuItem(value: Locale('fr'), child: Text('Français')),
              const PopupMenuItem(value: Locale('ar'), child: Text('العربية')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.account_circle,
                size: 80,
                color: isDarkMode ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(height: 20),
              Text(
                loc.createYourAccount,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              // Champ email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: loc.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.enterEmail;
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return loc.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: loc.password,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.enterPassword;
                  }
                  if (value.length < 6) {
                    return loc.weakPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ confirmation mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: loc.confirmPassword,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return loc.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 24),

              // Bouton d'inscription
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(loc.signUp),
              ),
              const SizedBox(height: 16),

              // Lien vers connexion
              TextButton(
                onPressed: () {
                  // Redirection vers la page de connexion (AuthScreen)
                  context.go('/sign-in'); // Remplace avec la route de la page de connexion
                },
                child: Text(loc.alreadyHaveAccount), // Texte en fonction de la langue
              ),
            ],
          ),
        ),
      ),
    );
  }
}
