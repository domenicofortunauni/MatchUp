import 'package:flutter/material.dart';
import '../../behaviors/AppLocalizations.dart';
import 'login_styles.dart';
import 'register_fields.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isLogin;
  final bool isLoading;
  final bool isPasswordVisible;

  final TextEditingController nome;
  final TextEditingController cognome;
  final TextEditingController username;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirmPassword;

  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;

  final String livello;

  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onResetPassword;
  final ValueChanged<String> onLivelloChanged;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.isLogin,
    required this.isLoading,
    required this.isPasswordVisible,
    required this.nome,
    required this.cognome,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.livello,
    required this.onToggleMode,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onResetPassword,
    required this.onLivelloChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Image.asset(
                'assets/images/app_icon_splash.png',
                height: 100,
                width: 100,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.sports_tennis,
                  size: 100,
                  color: primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                isLogin ? AppLocalizations.of(context)!.translate("Benvenuto")
                    : AppLocalizations.of(context)!.translate("Crea account"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isLogin
                    ? AppLocalizations.of(context)!.translate("Accedi per vedere le tue statistiche.")
                    : AppLocalizations.of(context)!.translate("Unisciti a MatchUP e inizia a vincere."),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),

              /// ===== REGISTER FIELDS (SOLO SE !isLogin) =====
              if (!isLogin) ...[
                  RegisterFields(
                    isLogin: isLogin,
                    nome: nome,
                    cognome: cognome,
                    username: username,
                    livello: livello,
                    onLivelloChanged: onLivelloChanged,
                  ),
                  const SizedBox(height: 16),
              ],

              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: loginInputDecoration(
                  context: context,
                  label:
                  AppLocalizations.of(context)!.translate("Email"),
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Inserisci l'email");
                  }
                  if (!value.contains('@')) {
                    return AppLocalizations.of(context)!.translate("Email non valida");
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: password,
                focusNode: passwordFocusNode,
                obscureText: !isPasswordVisible,
                textInputAction:
                isLogin ? TextInputAction.done : TextInputAction.next,
                onFieldSubmitted: (_) {
                  if (isLogin) {
                    onSubmit();
                  } else {
                    FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                  }
                },
                decoration: loginInputDecoration(
                  context: context,
                  label:
                  AppLocalizations.of(context)!.translate("Password"),
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    focusNode: FocusNode(skipTraversal: true),
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Inserisci la password");
                  }
                  if (!isLogin && value.length < 6) {
                    return AppLocalizations.of(context)!.translate("Minimo 6 caratteri");
                  }
                  return null;
                },
              ),

              if (!isLogin) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPassword,
                  focusNode: confirmPasswordFocusNode,
                  obscureText: !isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onSubmit(),
                  decoration: loginInputDecoration(
                    context: context,
                    label: AppLocalizations.of(context)!.translate("Conferma Password"),
                    icon: Icons.lock_outline_rounded,
                  ),
                  validator: (value) {
                    if (value != password.text) {
                      return AppLocalizations.of(context)!.translate("Le password non coincidono");
                    }
                    return null;
                  },
                ),
              ],

              if (isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onResetPassword,
                    child: Text(
                      AppLocalizations.of(context)!.translate("Password dimenticata?"),
                    ),
                  ),
                )
              else
                const SizedBox(height: 12),

              const SizedBox(height: 12),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: loginButtonStyle(context),
                  onPressed: isLoading ? null : onSubmit,
                  child: isLoading ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(isLogin ? AppLocalizations.of(context)!.translate("ACCEDI")
                        : AppLocalizations.of(context)!.translate("CREA ACCOUNT"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin
                        ? AppLocalizations.of(context)!.translate("Non hai un account? ")
                        : AppLocalizations.of(context)!.translate("Hai già un account? "),
                    style: TextStyle(
                      color:
                      isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: onToggleMode,
                    child: Text(
                      isLogin ? AppLocalizations.of(context)!.translate("Registrati")
                          : AppLocalizations.of(context)!.translate("Accedi"),
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}