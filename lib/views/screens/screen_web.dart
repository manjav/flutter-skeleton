import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app_export.dart';

class WebScreen extends AbstractScreen {
  WebScreen({super.key}) : super(Routes.onboarding);

  @override
  createState() => _ScreenState();
}

class _ScreenState extends AbstractScreenState<WebScreen> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(TColors.primary);

  @override
  void initState() {
    controller.loadRequest(Uri.parse(Get.arguments["url"]));
    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    super.initState();
  }

  @override
  Widget contentFactory(double paddingTop) {
    return WebViewWidget(controller: controller);
  }
}
