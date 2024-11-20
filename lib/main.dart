import 'package:flutter/material.dart';
import 'login_page.dart';  // Importa LoginPage
import 'register_page.dart';  // Importa RegisterPage
import 'sales_page.dart';  // Importa SalesPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurante Ventas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => SalesPage(title: 'Restaurante Ventas Home Page', username: ModalRoute.of(context)?.settings.arguments as String),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}