import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:url_launcher/url_launcher.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/providers/sharing/public_link_session_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/breadcrumbs.dart";
import "package:polder/screens/browser/widgets/transfers_button.dart";
import "package:polder/screens/shared/widgets/space_directory_view.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/deep_link/share_link_target.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/centered_progress.dart";
import "package:polder/widgets/shared/error_view.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/password_field.dart";

class PublicShareScreen extends ConsumerWidget {
  const PublicShareScreen({required this.code, required this.path, this.server, super.key});

  final String code;
  final String? server;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl =
        ref.watch(hostedServerUrlProvider) ??
        switch (server) {
          final server? when server.trim().isNotEmpty => ApiClientFactory.normalizeServerUrl(server),
          _ => ref.watch(currentAccountProvider)?.serverUrl,
        };
    if (serverUrl == null) {
      return _Frame(
        title: context.localized.appTitle,
        body: MessageView(icon: IconsaxPlusLinear.link_21, message: context.localized.publicShareNotFound),
      );
    }
    final space = LinkSpace(serverUrl: serverUrl, code: code);
    final session = ref.watch(publicLinkSessionProvider(space));
    final target = ShareLinkTarget(serverUrl: serverUrl, code: code);
    final title = session.value?.shownInfo.name ?? context.localized.appTitle;
    return _Frame(
      title: title,
      actions: [
        const TransfersButton(),
        if (kIsWeb) _OpenInAppButton(target: target),
        _OpenSignedInButton(target: target),
      ],
      floatingActionButton: _uploadButton(context, ref, space, session.value),
      body: switch (session) {
        AsyncValue(hasValue: true, :final value?) when !value.isUnlocked => _PasswordPrompt(space: space),
        AsyncValue(hasValue: true, :final value?) => _Contents(
          space: space,
          session: value,
          server: server,
          path: path,
        ),
        AsyncError(error: NotFoundException()) => MessageView(
          icon: IconsaxPlusLinear.link_21,
          message: context.localized.publicShareNotFound,
        ),
        AsyncError(:final error) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(publicLinkSessionProvider(space)),
        ),
        _ => const CenteredProgress(),
      },
    );
  }

  Widget? _uploadButton(BuildContext context, WidgetRef ref, LinkSpace space, PublicLinkSession? session) {
    final unlocked = session?.unlocked;
    if (unlocked == null || !unlocked.root.isDir || !ref.watch(spaceCapabilitiesProvider(space)).canUpload) return null;
    return FloatingActionButton.extended(
      icon: const Icon(IconsaxPlusLinear.document_upload),
      label: Text(context.localized.uploadFiles),
      onPressed: () =>
          ref.read(transfersProvider.notifier).pickAndUploadToSpace(SpaceLocation(space: space, path: path)),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.body, this.actions = const [], this.floatingActionButton});

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: [...actions, const SizedBox(width: 8)]),
    floatingActionButton: floatingActionButton,
    body: body,
  );
}

class _Contents extends ConsumerWidget {
  const _Contents({required this.space, required this.session, required this.server, required this.path});

  final LinkSpace space;
  final PublicLinkSession session;
  final String? server;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = session.shownInfo;
    final root = session.unlocked!.root.copyWith(name: info.name ?? session.unlocked!.root.name);
    final localized = context.localized;
    if (info.permissions.isUploadOnly) {
      return MessageView(
        icon: IconsaxPlusLinear.document_upload,
        message: localized.publicShareUploadOnly(info.owner?.name ?? ""),
      );
    }
    if (!root.isDir) return _SingleFile(space: space, entry: root, owner: info.owner);
    final atRoot = path == RemotePath.root;
    return PopScope(
      canPop: atRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !atRoot) {
          context.go(AppRoutes.publicShareAt(space.code, server: server, path: RemotePath.parent(path)));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Breadcrumbs(
                  path: path,
                  rootLabel: root.name,
                  onNavigate: (target) => context.go(AppRoutes.publicShareAt(space.code, server: server, path: target)),
                ),
              ),
              if (info.permissions.download)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    icon: const Icon(IconsaxPlusLinear.document_download),
                    label: Text(localized.downloadAll),
                    onPressed: () => ref
                        .read(transfersProvider.notifier)
                        .downloadFromSpace(space, FileEntry.folder(path, rootName: root.name)),
                  ),
                ),
            ],
          ),
          if (info.owner case final owner?)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(localized.sharedBy(owner.name), style: Theme.of(context).textTheme.bodySmall),
            ),
          Expanded(
            child: SpaceDirectoryView(
              location: SpaceLocation(space: space, path: path),
              onOpenFolder: (folder) => context.go(AppRoutes.publicShareAt(space.code, server: server, path: folder)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleFile extends StatelessWidget {
  const _SingleFile({required this.space, required this.entry, this.owner});

  final LinkSpace space;
  final FileEntry entry;
  final ShareTarget? owner;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpaceFileSheet(space: space, entry: entry),
            if (owner case final owner?)
              Text(context.localized.sharedBy(owner.name), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );
}

class _PasswordPrompt extends ConsumerStatefulWidget {
  const _PasswordPrompt({required this.space});

  final LinkSpace space;

  @override
  ConsumerState<_PasswordPrompt> createState() => _PasswordPromptState();
}

class _PasswordPromptState extends ConsumerState<_PasswordPrompt> {
  final _password = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              const Icon(IconsaxPlusLinear.lock_1, size: 48),
              Text(
                localized.publicShareLocked,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                Uri.parse(widget.space.serverUrl).host,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              PasswordField(
                label: localized.linkPassword,
                controller: _password,
                errorText: _error,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _unlock(),
              ),
              LoadingButton(label: localized.publicShareUnlock, loading: _loading, onPressed: _unlock),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    final localized = context.localized;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(publicLinkSessionProvider(widget.space).notifier).unlock(_password.text);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error) {
          UnauthorizedException() => localized.publicShareWrongPassword,
          _ when error.statusCode == 429 => localized.publicShareRateLimited,
          _ => localized.describeError(error),
        },
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _OpenInAppButton extends StatelessWidget {
  const _OpenInAppButton({required this.target});

  final ShareLinkTarget target;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(IconsaxPlusLinear.mobile),
    label: Text(context.localized.openInApp),
    onPressed: () => launchUrl(target.appUri, mode: LaunchMode.externalApplication),
  );
}

class _OpenSignedInButton extends ConsumerWidget {
  const _OpenSignedInButton({required this.target});

  final ShareLinkTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    if (!target.isOn(account?.serverUrl)) return const SizedBox.shrink();
    return TextButton.icon(
      icon: const Icon(IconsaxPlusLinear.folder_open),
      label: Text(context.localized.openInPolder),
      onPressed: () async {
        final location = await target.locationFor(ref.read(polderApiProvider));
        if (context.mounted && location != target.publicLocation) context.go(location);
      },
    );
  }
}
