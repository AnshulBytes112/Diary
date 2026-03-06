import 'package:flutter/material.dart';

import 'features/auth/forgot_password_page.dart';
import 'features/auth/sign_in_page.dart';
import 'features/auth/sign_up_page.dart';
import 'theme/app_theme.dart';

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: {
        SignUpPage.routeName: (_) => const SignUpPage(),
        SignInPage.routeName: (_) => const SignInPage(),
        ForgotPasswordPage.routeName: (_) => const ForgotPasswordPage(),
      },
      initialRoute: SignUpPage.routeName,
    );
  }
}

