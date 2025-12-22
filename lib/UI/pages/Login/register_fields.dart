import 'package:flutter/material.dart';
import '../../../model/support/Constants.dart';
import '../../behaviors/AppLocalizations.dart';
import 'login_styles.dart';

class RegisterFields extends StatelessWidget {
  final bool isLogin;
  final TextEditingController nome;
  final TextEditingController cognome;
  final TextEditingController username;
  final String livello;
  final ValueChanged<String> onLivelloChanged;

  const RegisterFields({
    super.key,
    required this.isLogin,
    required this.nome,
    required this.cognome,
    required this.username,
    required this.livello,
    required this.onLivelloChanged,
  });

  @override
  Widget build(BuildContext context) {
    final livelli = Constants.livelliKeys
        .map((k) => DropdownMenuItem<String>(value: k, child: Text(AppLocalizations.of(context)!.translate(k)),),).toList();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: nome,
                decoration: loginInputDecoration(
                  context: context,
                  label: AppLocalizations.of(context)!.translate("Nome"),
                  icon: Icons.person,
                ),
                validator: (v) {
                  if (isLogin) return null;
                  if (v == null || v.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Obbligatorio");
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cognome,
                decoration: loginInputDecoration(
                  context: context,
                  label:
                  AppLocalizations.of(context)!.translate("Cognome"),
                  icon: Icons.person_outline,
                ),
                validator: (v) {
                  if (isLogin) return null;
                  if (v == null || v.isEmpty) {
                    return AppLocalizations.of(context)!.translate("Obbligatorio");
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: username,
          decoration: loginInputDecoration(
            context: context,
            label:
            AppLocalizations.of(context)!.translate("Username"),
            icon: Icons.alternate_email,
          ),
          validator: (v) {
            if (isLogin) return null;
            if (v == null || v.isEmpty) {
              return AppLocalizations.of(context)!.translate("Inserisci un username");
            }
            if (v.length < 3) {
              return AppLocalizations.of(context)!.translate("Minimo 3 caratteri");
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: livello,
          items: livelli,
          onChanged: (v) => onLivelloChanged(v!),
          decoration: loginInputDecoration(
            context: context,
            label:
            AppLocalizations.of(context)!.translate("Livello"),
            icon: Icons.sports_tennis,
          ),
          validator: (v) {
            if (isLogin) return null;
            if (v == null) {
              return AppLocalizations.of(context)!.translate("Seleziona il livello");
            }
            return null;
          },
        ),
      ],
    );
  }
}
