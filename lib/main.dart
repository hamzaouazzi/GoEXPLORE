import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sailor/sailor.dart';

import 'core/theme/bloc/theme_bloc.dart';
import 'features/domain/entities/user.dart';
import 'features/presentation/bloc/login_bloc.dart';
import 'features/presentation/pages/login_page.dart';
import 'injection_container.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  Routes.createRoutes();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = serviceLocator<LoginBloc>();
            bloc.add(CheckLoggedInStateEvent());
            return bloc;
          },
        ),
        
      ], 
     
    );
  }

  void _displaySnackBar({
    BuildContext context,
    String message,
    bool isSuccessful,
  }) {
    Flushbar(
      //margin: const EdgeInsets.all(8.0),
      //borderRadius: 10.0,
      //padding: const EdgeInsets.all(0.0),
      // messageText: CustomSnackBar(
      //   message: message,
      //   isSuccessful: isSuccessful,
      // ),
      message: message,
      duration: Duration(seconds: 2),
    ).show(context);
  }
}

class Routes {
  static Sailor sailor = Sailor();

  static void createRoutes() {
    sailor.addRoutes([
      SailorRoute(
        name: LoginPage.routeName,
        builder: (_, args, params) => LoginPage(),
      ),
     
    ]);
  }
}
