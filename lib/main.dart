import 'package:GoEXPLORE/src/providers/users_provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sailor/sailor.dart';

import 'core/theme/bloc/theme_bloc.dart';
import 'features/domain/entities/user.dart';
import 'features/presentation/bloc/login_bloc.dart';
import 'features/presentation/pages/loading_page.dart';
import 'features/presentation/pages/login_page.dart';
import 'features/presentation/pages/profile_page.dart';
import 'features/presentation/pages/update_info_page.dart';
import 'injection_container.dart';
import 'src/pages/chat_page.dart';
import 'src/pages/home_page.dart';
import 'src/pages/image_message_view.dart';
import 'src/pages/settings_page.dart';

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
      child: ChangeNotifierProvider<UsersProvider>(
        create: (_) => UsersProvider(),
        child: BlocBuilder<ThemeBloc, AppThemeState>(
          builder: (_, state) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Chat App',
            theme: state.themeData,
            home: BlocListener<LoginBloc, LoginState>(
              listener: (ctx, state) {
                if (state is AlertMessageState) {
                  _displaySnackBar(
                    context: ctx,
                    message: state.message,
                    isSuccessful: true,
                  );
                } else if (state is ErrorState) {
                  _displaySnackBar(
                    context: ctx,
                    message: state.message,
                    isSuccessful: false,
                  );
                }
              },
              child: BlocBuilder<LoginBloc, LoginState>(
                builder: (ctx, state) {
                  if (state is LoggedInState) {
                    try {
                      serviceLocator.registerLazySingleton(() => state.user);
                    } catch (err) {}
                    return HomePage();
                  } else if (state is LoggedOutState ||
                      state is AccountDeletedState) {
                    serviceLocator.unregister(
                      instance: serviceLocator<User>(),
                    );
                    return LoginPage();
                  } else if (state is LoadingState) {
                    return LoadingPage();
                  } else if (state is AlertMessageState) {
                    try {
                      final currentUser = serviceLocator<User>();
                      return HomePage();
                    } catch (error) {
                      return LoginPage();
                    }
                  } else if (state is ErrorState) {
                    try {
                      final currentUser = serviceLocator<User>();
                      return HomePage();
                    } catch (error) {
                      return LoginPage();
                    }
                  } else {
                    return Center(
                      child: Text('Error Loading Screen'),
                    );
                  }
                },
              ),
            ),
            onGenerateRoute: Routes.sailor.generator(),
            navigatorKey: Routes.sailor.navigatorKey,
          ),
        ),
      ),
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
      SailorRoute(
        name: HomePage.routeName,
        builder: (_, args, params) => HomePage(),
      ),
      SailorRoute(
          name: ProfilePage.routeName,
          builder: (_, args, params) =>
              ProfilePage(userId: params.param('userId')),
          params: [SailorParam(name: 'userId')]),
      SailorRoute(
        name: ChatPage.routeName,
        builder: (_, args, params) => ChatPage(
          peerId: params.param('peerId'),
          peerName: params.param('peerName'),
          peerImageUrl: params.param('peerImageUrl'),
        ),
        params: [
          SailorParam(
            name: 'peerId',
            defaultValue: '',
            isRequired: true,
          ),
          SailorParam(
            name: 'peerName',
            defaultValue: '',
            isRequired: true,
          ),
          SailorParam(
            name: 'peerImageUrl',
            defaultValue: '',
            isRequired: true,
          ),
        ],
      ),
      SailorRoute(
        name: ImageMessageView.routeName,
        builder: (ctx, args, params) => ImageMessageView(
          imageUrl: params.param('imageUrl'),
        ),
        params: [
          SailorParam(
            name: 'imageUrl',
            isRequired: true,
          ),
        ],
      ),
      SailorRoute(
        name: UpdateInfoPage.routeName,
        builder: (_, args, params) {
          return UpdateInfoPage(
            isSigningUp: params.param('isSigningUp'),
          );
        },
        params: [
          SailorParam(name: 'isSigningUp'),
        ],
      ),
      SailorRoute(
        name: SettingsPage.routeName,
        builder: (_, args, params) => SettingsPage(),
      ),
    ]);
  }
}
