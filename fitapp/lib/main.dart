import 'package:firebase_core/firebase_core.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:fitapp/firestore/auth_methods.dart';
import 'package:fitapp/firebase_options.dart';
import 'package:fitapp/pages/overview.dart';
import 'package:fitapp/util/testappbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/pages/fitness.dart';
import 'package:fitapp/pages/history.dart';
import 'package:fitapp/pages/nutrition.dart';
import 'package:fitapp/pages/progress.dart';
import 'package:fitapp/pages/settings.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitapp/components/theme/theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitapp/components/theme/theme_utils.dart';

Future<int> _loadSelectedMode() async {
  final prefs = await SharedPreferences.getInstance();
  final themeModeIndex = prefs.getInt('themeMode') ?? 3; // Default to 3 if not found
  return themeModeIndex;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeModeIndex = await _loadSelectedMode();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(
          create: (context) => AppTheme()..themeMode = getThemeByIndex(themeModeIndex),
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
    return MaterialApp(
      theme: ThemeClass.lightTheme,
      darkTheme: ThemeClass.darkTheme,
      themeMode: context.watch<AppTheme>().themeMode,
      debugShowCheckedModeBanner: false,
      home: const NavBar(),
    );
  }
}
class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final GlobalKey<NavigatorState> overviewNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> fitnessNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> nutritionNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> historyNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> progressNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> settingsNavKey = GlobalKey<NavigatorState>();

  late int currentIndex;

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: true,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent)
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);

    return EliteTabScaffold(
      backgroundColor: Colors.transparent,
      tabBar: EliteTabBar(
        height: 60,
        inactiveColor: Colors.grey.shade500,
        activeColor: Colors.grey.shade200,
        backgroundColor: Colors.black.withOpacity(0),
        border: Border.all(
            color: Colors.transparent,
            width: 0.0,
            style: BorderStyle.none
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.run_circle_outlined),
            label: 'Fitness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_circle),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings_solid),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
//            print('current i = $currentIndex, clicked = $index');

          if (index == currentIndex) {
            switch (index) {
              case 0:
                overviewNavKey.currentState?.popUntil((r) => r.isFirst);
                break;
              case 1:
                fitnessNavKey.currentState?.popUntil((r) => r.isFirst);
                break;
              case 2:
                nutritionNavKey.currentState?.popUntil((r) => r.isFirst);
                break;
              case 3:
                historyNavKey.currentState?.popUntil((r) => r.isFirst);
                break;
              case 4:
                progressNavKey.currentState?.popUntil((r) => r.isFirst);
                break;
              case 5:
                settingsNavKey.currentState?.popUntil((r) => r.isFirst);
                break;
            }
          }

          currentIndex = index;
        },
      ),
      tabBuilder: (BuildContext context, int index) {
        currentIndex = index;
        return CupertinoTabView(
          builder: (BuildContext context) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  navigatorKey: overviewNavKey,
                  builder: (BuildContext context) {
                    return const Overview();
                  },
                );
              case 1:
                return CupertinoTabView(
                  navigatorKey: fitnessNavKey,
                  builder: (BuildContext context) {
                    return const Fitness();
                  },
                );
              case 2:
                return CupertinoTabView(
                  navigatorKey: nutritionNavKey,
                  builder: (BuildContext context) {
                    return const Nutrition();
                  },
                );
              case 3:
                return CupertinoTabView(
                  navigatorKey: historyNavKey,
                  builder: (BuildContext context) {
                    return const History();
                  },
                );
              case 4:
                return CupertinoTabView(
                  navigatorKey: progressNavKey,
                  builder: (BuildContext context) {
                    return const Progress();
                  },
                );
              case 5:
                return CupertinoTabView(
                  navigatorKey: settingsNavKey,
                  builder: (BuildContext context) {
                    return const Settings();
                  },
                );
              default:
                return const Overview();
            }
          },
        );
      },
    );
  }
}
