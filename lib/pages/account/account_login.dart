import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../components/error_message.dart';
import '../../components/gap.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../validators/validators.dart';
import '../components/form_group.dart';

class AccountLoginPage extends StatefulWidget {
  const AccountLoginPage({super.key});

  @override
  State<AccountLoginPage> createState() => _AccountLoginPageState();
}

class _AccountLoginPageState extends State<AccountLoginPage> {
  late final FormGroupController _alipan;
  late final FormGroupController _webdav;
  final _quarkCookieController = TextEditingController();
  bool _useQuarkCookieLogin = false;

  // 你的夸克 cookies，预填方便测试
  static const String _kQuarkCookies =
      '__kp=78c229d0-6630-11f1-99b3-df4530bc8ea5; __kps=AATAQ9dZ9ZLplFsKL2hkM7wp; '
      '__ktd=V9UMMm9IA188bNvxOEzkyg==; '
      '__pus=c9cec6782fcf1406569784858b3511f2AARlfjr3I+2WvwXpHYMP9YoHOIVqzEqnOB380512sHWtalm+fTKjo9/jhKbz36yZiiH2CGWHIFd7xbqBQFbuZNJo; '
      '__puus=078a79155913799cab38d60bf95320c2AATjBL9ijoa4mcb5Wo/pt+Vf+EM8bXTCj2CXxDeKmy3vhSLc8PmUPUx3z2kyXJC9FScAkVCEYNfmq6ARdFU5oEELL7UjVqyt/vV80XUS9CQpoGwQdNtG5g0DdF7E759BejQYWyM5/+gDY9TPHRaiopxNL6nePkE4TfFZOfWbwBKr52DKQJbqRDa/NA6o++C9FSTCjU8GheMFPKySBSK2A94U; '
      '__sdid=AASthbNGeaLOnSbX9LFfk7A7RwQVz46ybqrSWC9SIeoBMlfRsuM4/eMfLQ2MKMAxpE4=; '
      '__uid=AATAQ9dZ9ZLplFsKL2hkM7wp; _c_WBKFRo=XRiODpF4ej85xulm3iHJTZGmn3CGaKvXoM0AzacV; '
      '_UP_30C_6A_=sta2e6201f1kykf24vlng0u4ocvg4nmf; _UP_335_2B_=1; '
      '_UP_A4A_11_=wb9cf14950de413db2074226b4ded792; _UP_D_=pc; '
      '_UP_E37_B7_=sg19a4f1ab1f77d3fee9abfe1e5a3e9ef89; '
      '_UP_F7E_8D_=zGxYQNal9K1RPU%2F322Xua0PwKLOVbxJPcg0RzQPI6Knpe%2FVlExDLvwWk3%2BqxkwVyhdZ%2Bc09AyraclvYdENl26pP6NZpJjHSFAga2josF9WI5KqmBMZjstSyxXmZd2p0oVFkfbqd%2FhVix0H3H9ao5kfOK74MO9vf9vZ0QUAagmMeThL0Fyv73vNnFKDSDGkjZLaNgdmMlWwTS2zrP1PvuegL1ab%2BGtr1sq8pSdmROCVapcUe9jZI%2Bxm7LdwWVC57iqJOMnzaZtYmwPMpd0%2B7BZarlx5I0Wl5nDsG05Cf8pRZwZDzB3oYCMpS18nCC6SJfvOTidzNw8s%2FWtKAIxWbnCzZn4%2FJMBUub0OScUYeEhuslyLV%2Fu7Wakbw1NPb%2BGxTfdN9v97RwhiP0TZ9imWfrLxU4wR0Pq7NklczEGdRq2nIAcu7v22Uw2o%2FxMY0xBdeC9Korm5%2FNHnxl6K%2Bd6FXSoT9a3XIMQO359auZPiZWzrNlZe%2BqnOahXcx7KAhQIRqSOapSmL4ygJor4r5isJhRuDoXy7vJAVuH%2FRDtEJJ8rZTq0BdC23Bz%2B0MrsdgbK%2BiW; '
      '_UP_TG_=sta2e6201f1kykf24vlng0u4ocvg4nmf; _UP_TS_=sg19a4f1ab1f77d3fee9abfe1e5a3e9ef89; '
      'b-user-id=f8d3ea4b-2922-8415-d80b-d39e2da38881; '
      'isg=BMDAtwVXvqhDX0FcQP0RYvOekUiSSaQT2O45XjpRD1tutWPf4lxpo26HyR11BVzr; '
      'tfstk=gOJZmtAaItYIkE3k43Xqau4hNf6Odtu5SK_fmnxcfNbGhfd2TntrXiT6mZRV-nQgjmI03Wj1jlA_IfCV8wYHfR_fIZq2lnO6unnOmZYDuZOsOYt9XtBmPEkSFh3kUGuyu1bMxvxdc-4mO1vdmm2sP4MSdfqh3VuWcFjh99jA-GjcmRmFKgIVnGfGnD7h0gF0SEXmYDS5jij0nZj3tG_hotXDoHmFDwjGntYDxDSvzU-MmJS5scwjNi_gV9CNrhbUUHpFjX7reww03pjwYaxiw-2DLG5wdIhgXoBDshTFNCuzQTtMwEIkSP0NYd-y3QYndRW2xQvKp03ANAJYKW6ImMGKd8wI6800W5MwFOlTpgapaAHYn1e9mF1lQIDk_pjyRQMm3pJNTk40MRyx9Sr8rIn5DJv_rVVsMIFPDoe0_VwVhJBR2PYM6XRYai1fSFAsasFPDoUMSCT4M7SfG1..; '
      'xlly_s=1; __wpkreporterwid_=8764ecc9-a6ce-4530-07dd-54c9190ad512; '
      'ctoken=-4oka8iHWhZQxEo2lnE-GZmG; isQuark=true; '
      'isQuark.sig=hUgqObykqFom5Y09bll94T1sS9abT1X-4Df_lzgl8nM';

  DriverType _driverType = DriverType.alipan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _alipan = FormGroupController([
      FormItem(
        'token',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelRefreshToken,
        prefixIcon: Icons.shield_outlined,
        maxLines: 5,
        validator: (value) => requiredValidator(context, value),
      ),
      FormItem(
        'url',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelOauthUrl,
        prefixIcon: Icons.link,
        validator: (value) => urlValidator(context, value, true),
      ),
      FormItem(
        'username',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelClientId,
        helperText: AppLocalizations.of(context)!.formItemNotRequiredHelper,
        prefixIcon: Icons.abc,
      ),
      FormItem(
        'password',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelClientPwd,
        helperText: AppLocalizations.of(context)!.formItemNotRequiredHelper,
        prefixIcon: Icons.password,
      ),
    ]);
    _webdav = FormGroupController([
      FormItem(
        'url',
        labelText: 'Host',
        hintText: 'http://127.0.0.1:8090',
        prefixIcon: Icons.link,
        validator: (value) => urlValidator(context, value, true),
      ),
      FormItem(
        'username',
        labelText: AppLocalizations.of(context)!.loginFormItemLabelUsername,
        prefixIcon: Icons.account_circle_outlined,
      ),
      FormItem(
        'password',
        labelText: AppLocalizations.of(context)!.loginFormItemLabelPwd,
        prefixIcon: Icons.password,
        obscureText: true,
      ),
    ]);
  }

  @override
  void dispose() {
    _alipan.dispose();
    _webdav.dispose();
    _quarkCookieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pageTitleLogin),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _login)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children:
                    [DriverType.alipan, DriverType.quark, DriverType.webdav]
                        .map(
                          (ty) => [
                            Radio(
                              value: ty,
                              groupValue: _driverType,
                              onChanged: (t) => setState(() => _driverType = t!),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _driverType = ty),
                              child: Text(AppLocalizations.of(context)!.driverType(ty.name)),
                            ),
                            Gap.hSM,
                          ],
                        )
                        .flattened
                        .toList(),
              ),
            ),
          ),
          if (_driverType == DriverType.alipan) Expanded(child: FormGroup(controller: _alipan)),
          if (_driverType == DriverType.quark)
            Expanded(
              child: _useQuarkCookieLogin
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _quarkCookieController,
                            maxLines: 8,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Cookie',
                              hintText: '从浏览器复制 cookies 粘贴到这里',
                              helperText: '打开 pan.quark.cn → F12 → Application → Cookies → 复制所有 cookie',
                              helperMaxLines: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => setState(() => _useQuarkCookieLogin = false),
                            child: const Text('扫码登录'),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        WebViewWidget(
                          controller:
                              WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..setUserAgent(ua)
                                ..scrollBy(10000, 0)
                                ..loadRequest(Uri.parse('https://pan.quark.cn')),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: FilledButton.tonal(
                            onPressed: () => setState(() {
                              _useQuarkCookieLogin = true;
                              _quarkCookieController.text = _kQuarkCookies;
                            }),
                            child: const Text('Cookie 登录'),
                          ),
                        ),
                      ],
                    ),
            ),
          if (_driverType == DriverType.webdav) Expanded(child: FormGroup(controller: _webdav)),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (switch (_driverType) {
      DriverType.alipan => _alipan.validate(),
      DriverType.webdav => _webdav.validate(),
      DriverType.quark => true,
      _ => throw UnimplementedError(),
    }) {
      final data = switch (_driverType) {
        DriverType.alipan => _alipan.data,
        DriverType.webdav => _webdav.data,
        DriverType.quark => _useQuarkCookieLogin
            ? {'token': _quarkCookieController.text.trim()}
            : await _quarkCookie(),
        _ => throw UnimplementedError(),
      };
      if (!mounted) return;
      final flag = await showDialog<bool>(
        context: context,
        builder:
            (context) => _buildLoginLoading(
              Api.driverInsert(
                _driverType,
                url: data['url'],
                username: data['username'],
                password: data['password'],
                token: data['token'],
              ),
            ),
      );
      if ((flag ?? false) && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<Map<String, dynamic>> _quarkCookie() async {
    final cookieManager = WebviewCookieManager();
    final gotCookies = await cookieManager.getCookies('https://pan.quark.cn');
    final cookies = gotCookies.map((c) => '${c.name}=${c.value}').join('; ');
    return {'token': cookies};
  }

  Widget _buildLoginLoading(Stream<dynamic> stream) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.modalTitleNotification),
      content: StreamBuilder(
        stream: stream,
        builder:
            (context, snapshot) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop &&
                    (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.none ||
                        snapshot.hasData)) {
                  Navigator.of(context).pop();
                }
              },
              child: Builder(
                builder: (context) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final data = snapshot.requireData as Map<String, dynamic>;
                        if (data['type'] == 'qrcode') {
                          return SizedBox(
                            width: kQrSize,
                            height: kQrSize,
                            child: QrImageView(backgroundColor: Colors.white, data: data['qrcode_data'], size: kQrSize),
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(padding: EdgeInsets.all(17), child: CircularProgressIndicator()),
                              Text(AppLocalizations.of(context)!.modalNotificationLoadingText),
                            ],
                          );
                        }
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(padding: EdgeInsets.all(17), child: CircularProgressIndicator()),
                            Text(AppLocalizations.of(context)!.modalNotificationLoadingText),
                          ],
                        );
                      }
                    case ConnectionState.none:
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return ErrorMessage(
                          error: snapshot.error,
                          leading: const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        );
                      } else {
                        Future.delayed(const Duration(seconds: 1)).then((value) {
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        });
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                            Gap.vMD,
                            Text(AppLocalizations.of(context)!.modalNotificationSuccessText),
                          ],
                        );
                      }
                  }
                },
              ),
            ),
      ),
    );
  }
}
