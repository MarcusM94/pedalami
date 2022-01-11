import 'package:pedala_mi/utils/mobile_library.dart'
    if (dart.library.html) 'package:pedala_mi/utils/web_library.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Conditional().initFireBase();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(
        builder: (context, orientation) {
          SizeConfig().init(constraints, orientation);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.green.shade600,
              ),
              textSelectionTheme: TextSelectionThemeData(
                  selectionColor: Colors.lightGreen,
                  cursorColor: Colors.white,
                  selectionHandleColor: Colors.lightGreen),
            ),
            routes: Conditional().routes,
            home: Conditional().startPage,
          );
        },
      );
    });
  }
}
