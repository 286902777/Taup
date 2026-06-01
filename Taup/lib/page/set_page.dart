import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals/signals_flutter.dart';
import 'package:taup/page/base_page.dart';
import 'package:taup/page/my_web_page.dart';
import 'package:taup/tool/open_tool.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/assets.dart';

class SetPage extends StatefulWidget {
  const SetPage({super.key});

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  final versionInfo = Signal('');

  @override
  void initState() {
    super.initState();
    pageInfo().then((info) {
      versionInfo.value = info.version;
    });
  }

  Future<PackageInfo> pageInfo() async {
    PackageInfo page = await PackageInfo.fromPlatform();
    return page;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBtn: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: navBar(),
        body: contentWidget(),
      ),
    );
  }

  AppBar navBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              OpenTool.back(context);
            },
            child: Image.asset(
              Assets.assetsBack,
              width: 56,
              height: 24,
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget contentWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 28),
          Image.asset(
            Assets.assetsSetLogo,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 12),
          Watch(
            (ctx) => Text(
              'V${versionInfo.value}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24),
          itemWidget(Assets.assetsSetPolicy, 'Privacy Policy', 0),
          const Divider(height: 1, color: Color(0x16FFFFFF)),
          itemWidget(Assets.assetsSetTerms, 'Terms of Service', 1),
          const Divider(height: 1, color: Color(0x16FFFFFF)),
          itemWidget(Assets.assetsSetMail, 'Feedback', 2),
        ],
      ),
    );
  }

  Widget itemWidget(String icon, String title, int idx) {
    return GestureDetector(
      onTap: () {
        clickItem(idx);
      },
      child: SizedBox(
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, width: 24, height: 24, fit: BoxFit.cover),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Image.asset(
              Assets.assetsEnter,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  void clickItem(int idx) {
    switch (idx) {
      case 0:
        OpenTool.toWeb(context, WebLink.privacy);
      case 1:
        OpenTool.toWeb(context, WebLink.terms);
      default:
        openEmail();
    }
  }

  void openEmail() async {
    String email = 'ss@bbs.com';
    launchUrl(Uri(scheme: 'mailto', path: email));
  }
}
