import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'google_sheets_api.dart';
import 'homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleSheetsApi().init();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(
        duration: 5,
        goToPage: HomePage(),
      )));
}

class SplashPage extends StatelessWidget {
  int duration = 0;
  Widget goToPage;
  SplashPage({required this.goToPage, required this.duration});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: this.duration), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => this.goToPage));
    });

    return Scaffold(
      body: Center(
        child: Lottie.network(
            'https://assets10.lottiefiles.com/packages/lf20_rqes9zyp.json'),
      ),
    );
  }
}
