import 'package:better_days/core/navigator_service.dart';
import 'package:better_days/dashboard/profile_screen.dart';
import 'package:better_days/journal/journal_create_screen.dart';
import 'package:better_days/journal/journal_service.dart';
import 'package:better_days/mood/mood_service.dart';
import 'package:better_days/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:snacknload/snacknload.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'journal/journal_list_screen.dart';
import 'mood/mood_list_screen.dart';
import 'services/auth_service.dart';
import 'common/protected_route.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? token = await FlutterSecureStorage().read(key: 'token');
  if (token != null) {
    ApiService.instance.setAuthToken(token);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(
          token,
        )..autoLogin()),
        ChangeNotifierProvider<MoodService>(
          create: (_) => MoodService(),
          //update: (_, auth, moodService) => MoodService(),
        ),
        ChangeNotifierProvider<JournalService>(
          create: (_) => JournalService(),
          //update: (_, auth, journalService) => JournalService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData(
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFFFF8EE),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
    );
    return MaterialApp(
      title: 'Better days',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: themeData.copyWith(
        appBarTheme: themeData.appBarTheme.copyWith(
          backgroundColor: const Color(0xFFFFF8EE),
        )
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const ProtectedRoute(child: DashboardScreen()),
        '/profile': (context) => const ProtectedRoute(child: ProfileScreen()),
        '/mood': (context) => const ProtectedRoute(child: MoodChartScreen()),
        '/create-journal': (context) => const ProtectedRoute(child: JournalCreateScreen()),
        '/journals':
            (context) => const ProtectedRoute(child: JournalListScreen()),
      },
      builder: SnackNLoad.init(),
    );
  }
}
