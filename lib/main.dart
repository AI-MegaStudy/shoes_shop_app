import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shoes_shop_app/firebase_options.dart';
import 'package:shoes_shop_app/theme/theme_provider.dart';
import 'package:shoes_shop_app/view/main/auth/login_view.dart';

Future<void> main() async {
  // Flutter 바인딩 초기화 (플러그인 사용 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // GetStorage 초기화 (get_storage는 GetX와 독립적으로 사용 가능)
  await GetStorage.init();

  // GetStorage에서 DB 초기화 완료 여부 확인
  // TODO: DB 초기화 로직이 필요할 때 주석 해제
  // final storage = GetStorage();
  /*
  final isDBInitialized = storage.read<bool>(config.storageKeyDBInitialized) ?? false;

  // DB가 초기화되지 않았을 때만 초기화 및 더미 데이터 삽입
  if (!isDBInitialized) {
    // 데이터베이스 초기화 (DatabaseManager 사용)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '${config.dbName}${config.dbFileExt}');
    
   
    // 초기화 완료 플래그 저장
    await storage.write(config.storageKeyDBInitialized, true);
  }
  */
  // GT ADDED: Firebase initialize
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // 시스템에서 설정한 색상으로 초기화

  final Color _seedColor = Colors.deepPurple;

  // GetX navigation을 위한 GlobalKey
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      onToggleTheme: _toggleTheme,
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter Demo',
        themeMode: _themeMode,
        theme: ThemeData(brightness: Brightness.light, colorSchemeSeed: _seedColor),
        darkTheme: ThemeData(brightness: Brightness.dark, colorSchemeSeed: _seedColor),
        home: const LoginView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
