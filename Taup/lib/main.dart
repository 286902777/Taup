import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:media_kit/media_kit.dart';
import 'package:taup/page/start_page.dart';
import 'package:taup/tool/bus_tool.dart';
import 'package:taup/tool/cache_tool.dart';
import 'package:taup/tool/config_tool.dart';
import 'package:taup/tool/data_tool.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initGet();
  runApp(const MyApp());
}

Future initGet() async {
  final getIt = GetIt.instance;
  getIt.registerSingleton<BusTool>(BusTool());
  getIt.registerSingleton<ConfigTool>(ConfigTool());
  getIt.registerSingleton<CacheTool>(CacheTool());
  getIt.registerSingleton<DataTool>(DataTool());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      home: StartPage(),
    );
  }
}
