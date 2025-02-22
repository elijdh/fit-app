import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:provider/provider.dart';
import 'package:fitapp/components/theme/theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitapp/components/theme/theme_utils.dart';

class UserAppearance extends StatefulWidget {
  const UserAppearance({Key? key}) : super(key: key);

  @override
  _UserAppearanceState createState() => _UserAppearanceState();
}

class _UserAppearanceState extends State<UserAppearance> {
  late ThemeData _selectedMode;

  @override
  void initState() {
    _loadSelectedMode();
    super.initState();
  }

  Future<void> _loadSelectedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 3; // Default to 3 if not found
    final appTheme = context.read<AppTheme>();
    setState(() {
      appTheme.themeMode = getThemeByIndex(themeModeIndex);
    });
  }

  Future<void> _saveSelectedMode(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rounded Edge Cards'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeSwitchCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitchCard(BuildContext context) {
    AppTheme appTheme = context.read<AppTheme>();
    ThemeMode currentThemeMode = appTheme.themeMode;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Theme",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            RadioListTile(
              title: const Text("Light"),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (value) {
                setState(() {
                  _selectedMode = ThemeClass.lightTheme;
                  appTheme.themeMode = ThemeMode.light;
                  _saveSelectedMode(1); // Save the selected mode index
                });
              },
            ),
            RadioListTile(
              title: const Text("Dark"),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (value) {
                setState(() {
                  _selectedMode = ThemeClass.darkTheme;
                  appTheme.themeMode = ThemeMode.dark;
                  _saveSelectedMode(2); // Save the selected mode index
                });
              },
            ),
            RadioListTile(
              title: const Text("System"),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (value) {
                setState(() {
                  _selectedMode = ThemeClass.systemTheme;
                  appTheme.themeMode = ThemeMode.system;
                  _saveSelectedMode(3); // Save the selected mode index
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}