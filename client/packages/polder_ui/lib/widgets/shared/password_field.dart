import "package:material_ui/material_ui.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_ui/util/localization_helper.dart";

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    this.controller,
    this.initialValue,
    this.autofillHints,
    this.errorText,
    this.helperText,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final String? helperText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: !_visible,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          tooltip: _visible ? localized.hidePassword : localized.showPassword,
          icon: Icon(_visible ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye),
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
    );
  }
}
