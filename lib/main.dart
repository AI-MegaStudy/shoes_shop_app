import 'package:shoes_shop_app/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shoes_shop_app/theme/theme_provider.dart';
import 'package:shoes_shop_app/view/home.dart';
import 'package:shoes_shop_app/view/user/auth/login_view.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_login_view.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_mobile_block_view.dart';


Future<void> main() async {
  // GetStorage 초기화 (get_storage는 GetX와 독립적으로 사용 가능)
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

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
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: _seedColor,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: _seedColor,
        ),
        initialRoute: config.routeLogin,
        routes: {
          config.routeLogin: (context) => const LoginView(),
          config.routeHome: (context) => const Home(),
          config.routeAdminLogin: (context) => const AdminLoginView(),
          config.routeAdminMobileBlock: (context) => const AdminMobileBlockView(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
