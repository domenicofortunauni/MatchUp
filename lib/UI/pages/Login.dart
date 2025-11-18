import 'package:flutter/material.dart';
import 'package:matchup/UI/pages/Layout.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true; // true = Modalità Login, false = Modalità Registrazione
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simuliamo l'attesa (Login o Registrazione)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Layout(title: "MatchUP")),
        );
      }
    }
  }

  // Funzione per cambiare modalità
  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/app_icon_splash.png',
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 16),

                Text(
                  _isLogin ? AppLocalizations.of(context)!.translate("Bentornato") : AppLocalizations.of(context)!.translate("Crea account"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? AppLocalizations.of(context)!.translate("Accedi per vedere le tue statistiche.")
                      : AppLocalizations.of(context)!.translate("Unisciti a MatchUP e inizia a vincere."),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                if (!_isLogin) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nomeController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: "Nome",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: inputFillColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: (value) {
                            if (_isLogin) return null;
                            if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Obbligatorio");
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: TextFormField(
                          controller: _cognomeController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.translate("Cognome"),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: inputFillColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: (value) {
                            if (_isLogin) return null;
                            if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Obbligatorio");
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate("Email"),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: inputFillColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Inserisci l'email");
                    if (!value.contains('@')) return AppLocalizations.of(context)!.translate("Email non valida");
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate("Password"),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: inputFillColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate("Inserisci la password");
                    if (!_isLogin && value.length < 6) return AppLocalizations.of(context)!.translate("Minimo 6 caratteri");
                    return null;
                  },
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate("Conferma Password"),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                    validator: (value) {
                      if (_isLogin) return null;
                      if (value != _passwordController.text) return AppLocalizations.of(context)!.translate("Le password non coincidono");
                      return null;
                    },
                  ),
                ],

                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(AppLocalizations.of(context)!.translate("Password dimenticata?")),
                    ),
                  )
                else
                  const SizedBox(height: 24),

                if (_isLogin) const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                      _isLogin ? AppLocalizations.of(context)!.translate("ACCEDI") : AppLocalizations.of(context)!.translate("CREA ACCOUNT"),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? AppLocalizations.of(context)!.translate("Non hai un account? ") : AppLocalizations.of(context)!.translate("Hai già un account? "),
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: _toggleMode,
                      child: Text(
                        _isLogin ? AppLocalizations.of(context)!.translate("Registrati") : AppLocalizations.of(context)!.translate("Accedi"),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}