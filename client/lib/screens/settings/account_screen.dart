import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/account.dart";
import "package:polder/models/user.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/appearance_settings.dart";
import "package:polder/widgets/shared/image_source_menu.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/user_avatar.dart";

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final localized = context.localized;
    return AppPage(
      title: Text(localized.account),
      body: account == null
          ? const SizedBox.shrink()
          : ReadableWidth(
              maxWidth: 720,
              builder: (context, inset) => ListView(
                padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  NavGroup(
                    title: localized.userIcon,
                    children: [_AvatarEditor(account: account)],
                  ),
                  NavGroup(
                    title: localized.profile,
                    children: [_ProfileForm(user: account.user)],
                  ),
                  NavGroup(
                    title: localized.appearance,
                    children: const [Padding(padding: EdgeInsets.all(20), child: AppearanceSettings())],
                  ),
                ],
              ),
            ),
    );
  }
}

class _AvatarEditor extends ConsumerWidget {
  const _AvatarEditor({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localized = context.localized;
    final notifier = ref.read(currentUserProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 16,
        children: [
          UserAvatar(user: account.user, serverUrl: account.serverUrl, size: 72),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.user.displayName, style: theme.textTheme.titleMedium),
                Text(
                  account.handle,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  localized.userIconHint,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (account.user.avatar != null)
            IconButton(
              tooltip: localized.remove,
              icon: const Icon(IconsaxPlusLinear.trash),
              onPressed: () => context.runWithFeedback(notifier.removeAvatar()),
            ),
          ImageSourceMenu(
            onSelected: (source) => _pick(context, ref, source),
            builder: (open) => IconButton(
              tooltip: localized.change,
              icon: const Icon(IconsaxPlusLinear.gallery_edit),
              onPressed: open,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref, ImageSource source) async {
    final images = await pickImages(context, ref, source, multiple: false);
    if (images.isEmpty || !context.mounted) return;
    final notifier = ref.read(currentUserProvider.notifier);
    await context.runWithFeedback(images.first().then(notifier.setAvatar));
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.user});

  final User user;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final _firstName = TextEditingController(text: widget.user.profile.firstName);
  late final _lastName = TextEditingController(text: widget.user.profile.lastName);
  late final _displayName = TextEditingController(text: widget.user.profile.displayName);
  late final _email = TextEditingController(text: widget.user.profile.email);
  late final _age = TextEditingController(text: widget.user.profile.age?.toString() ?? "");
  late final _address = TextEditingController(text: widget.user.profile.address);

  late final _controllers = [_firstName, _lastName, _displayName, _email, _age, _address];

  var _saving = false;

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changed() => setState(() {});

  UserProfile get _edited => UserProfile(
    firstName: _firstName.text.trim(),
    lastName: _lastName.text.trim(),
    displayName: _displayName.text.trim(),
    email: _email.text.trim(),
    age: int.tryParse(_age.text),
    address: _address.text.trim(),
  );

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final edited = _edited;
    final firstNameShown = edited.firstName.isEmpty ? widget.user.username : edited.firstName;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(child: _field(_firstName, localized.firstName, hint: widget.user.username)),
              Expanded(child: _field(_lastName, localized.lastName)),
            ],
          ),
          _field(_displayName, localized.displayName, hint: firstNameShown, helper: localized.displayNameHint),
          _field(_email, localized.email, keyboardType: TextInputType.emailAddress, autofill: AutofillHints.email),
          _field(
            _age,
            localized.age,
            keyboardType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
          ),
          _field(
            _address,
            localized.address,
            keyboardType: TextInputType.streetAddress,
            autofill: AutofillHints.fullStreetAddress,
            maxLines: 3,
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: LoadingButton(
              label: localized.save,
              loading: _saving,
              onPressed: edited == widget.user.profile ? null : _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    String? helper,
    TextInputType? keyboardType,
    String? autofill,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: formatters,
    autofillHints: autofill == null ? null : [autofill],
    minLines: 1,
    maxLines: maxLines,
    decoration: InputDecoration(labelText: label, hintText: hint, helperText: helper),
  );

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.localized.profileSaved;
    setState(() => _saving = true);
    final succeeded = await context.runWithFeedback(ref.read(currentUserProvider.notifier).saveProfile(_edited));
    if (!mounted) return;
    setState(() => _saving = false);
    if (succeeded) messenger.showSnackBar(SnackBar(content: Text(saved)));
  }
}
