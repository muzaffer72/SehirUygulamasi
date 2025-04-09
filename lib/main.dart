import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/screens/navigation/main_navigation_screen.dart';
import 'package:sikayet_var/screens/posts/create_post_screen.dart';
import 'package:sikayet_var/screens/posts/post_detail_screen.dart';
import 'package:sikayet_var/screens/surveys/survey_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  // Initialize timeago
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  
  runApp(
    const ProviderScope(
      child: SikayetVarApp(),
    ),
  );
}

class SikayetVarApp extends StatelessWidget {
  const SikayetVarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ŞikayetVar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.amber,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.amber,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
      routes: {
        '/create_problem': (context) => const CreatePostScreen(type: PostType.problem),
        '/create_suggestion': (context) => const CreatePostScreen(type: PostType.general),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/post_detail') {
          final post = settings.arguments as Post;
          return MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          );
        }
        
        if (settings.name == '/survey_detail') {
          final survey = settings.arguments as Survey;
          return MaterialPageRoute(
            builder: (context) => SurveyDetailScreen(survey: survey),
          );
        }
        
        return null;
      },
    );
  }
}