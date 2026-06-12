import 'package:api/api.dart' hide PageData;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../components/async_image.dart';
import '../../components/error_message.dart';
import '../../components/future_builder_handler.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../account/account_login.dart';
import '../utils/notification.dart';
import '../viewers/file_viewer.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeTabBrowser),
      ),
      body: FutureBuilderHandler<List<DriverAccount>>(
        future: Api.driverQueryAll(),
        builder: (context, snapshot) {
          final accounts = snapshot.requireData;
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const NoData(),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _addAccount,
                    icon: const Icon(Icons.add),
                    label: const Text('添加账号'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: accounts.length + 1,
              itemBuilder: (context, index) {
                if (index == accounts.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: FilledButton.tonalIcon(
                        onPressed: _addAccount,
                        icon: const Icon(Icons.add),
                        label: const Text('添加账号'),
                      ),
                    ),
                  );
                }
                final account = accounts[index];
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: account.avatar == null
                          ? Icon(_driverIcon(account.type), size: 32)
                          : AsyncImage(account.avatar!, radius: BorderRadius.circular(8)),
                    ),
                    title: Text(account.name),
                    subtitle: Text(AppLocalizations.of(context)!.driverType(account.type.name)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openFileBrowser(account),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _driverIcon(DriverType type) {
    return switch (type) {
      DriverType.local => Icons.storage,
      DriverType.webdav => Icons.cloud_outlined,
      DriverType.alipan => Icons.cloud,
      DriverType.quark => Icons.cloud,
      DriverType.emby => Icons.movie_filter_outlined,
      DriverType.jellyfin => Icons.movie_filter_outlined,
    };
  }

  Future<void> _addAccount() async {
    final flag = await navigateTo<bool>(context, const AccountLoginPage());
    if (flag ?? false) setState(() {});
  }

  Future<void> _openFileBrowser(DriverAccount account) async {
    final controller = FileViewerController<DriverFile>();
    await FilePicker.showFilePicker(
      context,
      controller: controller,
      type: FilePickerType.remote,
      defaultTitle: Text(account.name),
      titleBuilder: (item) => Text(item?.name ?? account.name),
      actions: [
        PopupMenuButton(
          offset: const Offset(1, 0),
          tooltip: '',
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  onTap: () async {
                    final filename = await showDialog<String>(
                      context: context,
                      builder: (context) => FilenameDialog(
                        dialogTitle: AppLocalizations.of(context)!.buttonNewFolder,
                      ),
                    );
                    if (filename != null && context.mounted) {
                      final resp = await showNotification(
                        context,
                        Api.fileMkdir(account.id, controller.currentItem.value?.id ?? '/', filename),
                      );
                      if (resp?.error == null) {
                        controller.refresh();
                      }
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: const Icon(Icons.folder_open_rounded),
                    title: Text(AppLocalizations.of(context)!.buttonNewFolder),
                  ),
                ),
              ],
        ),
      ],
      firstPageErrorIndicatorBuilder: (_) => Center(child: ErrorMessage(error: controller.error)),
      noItemsFoundIndicatorBuilder: (_) => const NoData(),
      fetchData: (index) async {
        final items = await Api.fileList(account.id, controller.currentItem.value?.id ?? '/');
        return PageData(items: items, count: items.length, limit: 99999999);
      },
      itemBuilder: (context, item, index) {
        return FileViewer(
          item: item,
          onRefresh: controller.refresh,
          onPage: () => controller.nextPage(item),
          onRemove: () => Api.fileRemove(account.id, item.id),
          onRename: (filename) => Api.fileRename(account.id, item.id, filename),
        );
      },
    );
    controller.dispose();
    if (!context.mounted) return;
    setState(() {});
  }
}
