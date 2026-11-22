import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/server_settings.dart";
import "package:polder/providers/admin/server_settings_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/credential_rules.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/password_field.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

class AdminMailScreen extends ConsumerWidget {
  const AdminMailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppPage(
    title: Text(context.localized.emailSettings),
    body: AsyncValueView<ServerSettings>(
      value: ref.watch(serverSettingsProvider),
      onRetry: () => ref.invalidate(serverSettingsProvider),
      data: (settings) => ReadableWidth(
        maxWidth: 720,
        builder: (context, inset) => ListView(
          padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            _MailStatus(settings: settings),
            _ServerGroup(settings: settings),
            _SenderGroup(settings: settings),
            _TestGroup(settings: settings),
          ],
        ),
      ),
    ),
  );
}

extension on ServerSettings {
  bool get mailConfigured => smtpHost.isNotEmpty && smtpFrom.isNotEmpty;

  bool get mailEditable => !smtpManagedByConfig;
}

class _MailStatus extends StatelessWidget {
  const _MailStatus({required this.settings});

  final ServerSettings settings;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final colors = Theme.of(context).colorScheme;
    final configured = settings.mailConfigured;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card.filled(
        color: configured ? colors.primaryContainer : colors.surfaceContainerHigh,
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(
            configured ? IconsaxPlusLinear.sms_tracking : IconsaxPlusLinear.sms_notification,
            color: configured ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          ),
          title: Text(configured ? localized.emailOn : localized.emailOff),
          subtitle: Text(
            [
              configured ? localized.emailOnHint : localized.emailOffHint,
              if (settings.smtpManagedByConfig) localized.emailManagedByConfig,
            ].join("\n\n"),
          ),
        ),
      ),
    );
  }
}

class _ServerGroup extends ConsumerWidget {
  const _ServerGroup({required this.settings});

  final ServerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final notifier = ref.read(serverSettingsProvider.notifier);
    final editable = settings.mailEditable;
    return NavGroup(
      title: localized.mailServerGroup,
      children: [
        NavEntry(
          icon: IconsaxPlusLinear.global,
          title: localized.mailServerHost,
          subtitle: settings.smtpHost.isEmpty ? localized.notSet : settings.smtpHost,
          onTap: editable
              ? () => _editText(
                  context,
                  title: localized.mailServerHost,
                  initial: settings.smtpHost,
                  save: notifier.setSmtpHost,
                )
              : null,
        ),
        NavEntry(
          icon: IconsaxPlusLinear.lock_1,
          title: localized.mailSecurity,
          subtitle: _securityLabel(context, settings.smtpSecurity),
          onTap: editable ? () => _chooseSecurity(context, notifier) : null,
        ),
        NavEntry(
          icon: IconsaxPlusLinear.hashtag,
          title: localized.mailServerPort,
          subtitle: settings.smtpPort == 0
              ? localized.mailServerPortDefault(_defaultPort(settings.smtpSecurity))
              : "${settings.smtpPort}",
          onTap: editable ? () => _editPort(context, notifier) : null,
        ),
        NavEntry(
          icon: IconsaxPlusLinear.user,
          title: localized.mailUsername,
          subtitle: settings.smtpUsername.isEmpty ? localized.mailUsernameNone : settings.smtpUsername,
          onTap: editable
              ? () => _editText(
                  context,
                  title: localized.mailUsername,
                  initial: settings.smtpUsername,
                  save: notifier.setSmtpUsername,
                )
              : null,
        ),
        NavEntry(
          icon: IconsaxPlusLinear.key,
          title: localized.password,
          subtitle: settings.smtpPasswordSet ? localized.mailPasswordSaved : localized.notSet,
          onTap: editable ? () => _editPassword(context, notifier) : null,
        ),
      ],
    );
  }

  Future<void> _chooseSecurity(BuildContext context, ServerSettingsNotifier notifier) async {
    final choice = await showDialog<MailSecurity>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.localized.mailSecurity),
        children: [
          RadioGroup<MailSecurity>(
            groupValue: settings.smtpSecurity,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              children: [
                for (final security in MailSecurity.values)
                  RadioListTile<MailSecurity>(
                    value: security,
                    title: Text(_securityLabel(context, security)),
                    subtitle: Text(_securityHint(context, security)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (choice != null && choice != settings.smtpSecurity && context.mounted) {
      await context.runWithFeedback(notifier.setSmtpSecurity(choice));
    }
  }

  Future<void> _editPort(BuildContext context, ServerSettingsNotifier notifier) async {
    final localized = context.localized;
    final value = await showTextInputDialog(
      context,
      title: localized.mailServerPort,
      label: localized.mailServerPortLabel,
      confirmLabel: localized.save,
      initialValue: settings.smtpPort == 0 ? "" : "${settings.smtpPort}",
      isValid: (value) => value.trim().isEmpty || _validPort(value.trim()),
    );
    if (value == null || !context.mounted) return;
    await context.runWithFeedback(notifier.setSmtpPort(int.tryParse(value.trim()) ?? 0));
  }

  Future<void> _editPassword(BuildContext context, ServerSettingsNotifier notifier) async {
    final value = await showDialog<String>(context: context, builder: (_) => const _MailPasswordDialog());
    if (value != null && context.mounted) await context.runWithFeedback(notifier.setSmtpPassword(value));
  }
}

class _SenderGroup extends ConsumerWidget {
  const _SenderGroup({required this.settings});

  final ServerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final notifier = ref.read(serverSettingsProvider.notifier);
    return NavGroup(
      title: localized.mailSenderGroup,
      children: [
        NavEntry(
          icon: IconsaxPlusLinear.send_2,
          title: localized.mailFrom,
          subtitle: settings.smtpFrom.isEmpty ? localized.mailFromHint : settings.smtpFrom,
          onTap: settings.mailEditable
              ? () => _editText(
                  context,
                  title: localized.mailFrom,
                  label: localized.mailFromLabel,
                  initial: settings.smtpFrom,
                  save: notifier.setSmtpFrom,
                )
              : null,
        ),
      ],
    );
  }
}

class _TestGroup extends ConsumerWidget {
  const _TestGroup({required this.settings});

  final ServerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final ownAddress = ref.watch(currentUserProvider).value?.profile.email ?? "";
    return NavGroup(
      title: localized.mailTestGroup,
      children: [
        NavEntry(
          icon: IconsaxPlusLinear.direct_send,
          title: localized.sendTestEmail,
          subtitle: settings.mailConfigured ? localized.sendTestEmailHint : localized.sendTestEmailNeedsServer,
          onTap: settings.mailConfigured ? () => _sendTest(context, ref, ownAddress) : null,
        ),
      ],
    );
  }

  Future<void> _sendTest(BuildContext context, WidgetRef ref, String ownAddress) async {
    final localized = context.localized;
    final to = await showTextInputDialog(
      context,
      title: localized.sendTestEmail,
      label: localized.mailTestRecipient,
      confirmLabel: localized.send,
      initialValue: ownAddress,
      isValid: CredentialRules.isValidEmail,
    );
    if (to == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final sent = await context.runWithFeedback(ref.read(serverSettingsProvider.notifier).sendTestEmail(to: to.trim()));
    if (sent) messenger?.showSnackBar(SnackBar(content: Text(localized.testEmailSent(to.trim()))));
  }
}

class _MailPasswordDialog extends StatefulWidget {
  const _MailPasswordDialog();

  @override
  State<_MailPasswordDialog> createState() => _MailPasswordDialogState();
}

class _MailPasswordDialogState extends State<_MailPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.mailPassword),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(localized.mailPasswordHint),
            PasswordField(
              label: localized.password,
              controller: _controller,
              autofocus: true,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.cancel)),
        TextButton(onPressed: () => Navigator.of(context).pop(""), child: Text(localized.remove)),
        FilledButton(onPressed: () => Navigator.of(context).pop(_controller.text), child: Text(localized.save)),
      ],
    );
  }
}

Future<void> _editText(
  BuildContext context, {
  required String title,
  required String initial,
  required Future<void> Function(String value) save,
  String? label,
}) async {
  final value = await showTextInputDialog(
    context,
    title: title,
    label: label ?? title,
    confirmLabel: context.localized.save,
    initialValue: initial,
    isValid: (_) => true,
  );
  if (value != null && context.mounted) await context.runWithFeedback(save(value.trim()));
}

bool _validPort(String value) {
  final port = int.tryParse(value);
  return port != null && port > 0 && port <= 65535;
}

int _defaultPort(MailSecurity security) => switch (security) {
  MailSecurity.starttls => 587,
  MailSecurity.tls => 465,
  MailSecurity.none => 25,
};

String _securityLabel(BuildContext context, MailSecurity security) => switch (security) {
  MailSecurity.starttls => context.localized.mailSecurityStartTls,
  MailSecurity.tls => context.localized.mailSecurityTls,
  MailSecurity.none => context.localized.mailSecurityNone,
};

String _securityHint(BuildContext context, MailSecurity security) => switch (security) {
  MailSecurity.starttls => context.localized.mailSecurityStartTlsHint,
  MailSecurity.tls => context.localized.mailSecurityTlsHint,
  MailSecurity.none => context.localized.mailSecurityNoneHint,
};
