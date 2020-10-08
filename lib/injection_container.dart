import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/utils/input_validator.dart';
import 'features/data/datasources/login_local_data_source.dart';
import 'features/data/datasources/login_remote_data_source.dart';
import 'features/data/repositories/login_repository_impl.dart';
import 'features/domain/repositories/login_repository.dart';
import 'features/domain/usecases/get_logged_in_user_data.dart';
import 'features/domain/usecases/sign_in_with_google.dart';
import 'features/domain/usecases/sign_out_with_google.dart';
import 'features/domain/usecases/sing_in_with_email_password.dart';
import 'features/domain/usecases/sing_in_with_facebook.dart';
import 'features/domain/usecases/sing_up_with_email_password.dart';
import 'features/presentation/bloc/login_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  //! Features - UserAccout(Login)

  serviceLocator.registerFactory(
    () => LoginBloc(
      signInWithGoogle: serviceLocator(),
      signOutWithGoogle: serviceLocator(),
      getLoggedInUserData: serviceLocator(),
      signInWithEmailAndPassword: serviceLocator(),
      signUpWithEmailAndPassword: serviceLocator(),
      signInWithFacebook: serviceLocator(),
    ),
  );

  //Use Cases
  serviceLocator.registerLazySingleton(
    () => SignInWithGoogle(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SignOutWithGoogle(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetLoggedInUserData(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SignInWithEmailAndPassword(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SignUpWithEmailAndPassword(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SignInWithFacebook(repository: serviceLocator()),
  );

  //Repository
  serviceLocator.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDataSource: serviceLocator(),
      networkInfo: serviceLocator(),
    ),
  );

  //Data Sources
  serviceLocator.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(
      firebaseAuth: serviceLocator(),
      firestoreInstance: serviceLocator(),
      googleSignIn: serviceLocator(),
      storage: serviceLocator(),
      facebookLogin: serviceLocator(),
      firebaseMessaging: serviceLocator(),
      flutterLocalNotifications: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton<LoginLocalDataSource>(
    () => LoginLocalDataSourceImpl(preferences: serviceLocator()),
  );

  //!Core

  //NetworInfo
  serviceLocator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );

  serviceLocator.registerLazySingleton(() => InputValidator());

  //! External
  serviceLocator.registerLazySingleton(() => http.Client());
  serviceLocator.registerLazySingleton(() => GoogleSignIn());
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => Firestore.instance);
  serviceLocator.registerLazySingleton(() => FirebaseStorage.instance);
  serviceLocator.registerLazySingleton(() => FirebaseMessaging());
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
  serviceLocator.registerLazySingleton(() => FacebookLogin());

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final androidInitializationSettings =
      AndroidInitializationSettings('chat_icon');
  final iosInitializationSettings = IOSInitializationSettings();
  final initializationSettings = InitializationSettings(
      android: androidInitializationSettings, iOS: iosInitializationSettings);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  serviceLocator.registerLazySingleton(() => flutterLocalNotificationsPlugin);
}
