import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../domain/usecases/sing_in_with_facebook.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_logged_in_user_data.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out_with_google.dart';
import '../../domain/usecases/sing_in_with_email_password.dart';
import '../../domain/usecases/sing_up_with_email_password.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOutWithGoogle signOutWithGoogle;
  final GetLoggedInUserData getLoggedInUserData;
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword signUpWithEmailAndPassword;
  final SignInWithFacebook signInWithFacebook;

  LoginBloc({
    @required this.signInWithFacebook,
    @required this.signInWithGoogle,
    @required this.signOutWithGoogle,
    @required this.getLoggedInUserData,
    @required this.signInWithEmailAndPassword,
    @required this.signUpWithEmailAndPassword,
  }) : super(null);

  @override
  LoginState get initialState => InitialState();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is SignInWithGoogleEvent) {
      yield LoadingState();

      yield* _signInOrSignUpEitherHandler(() => signInWithGoogle(NoParam()));
    } else if (event is SignOutWithGoogleEvent) {
      yield LoadingState();

      final signOutGoogleEither = await signOutWithGoogle(NoParam());

      yield signOutGoogleEither.fold(
        (failure) => ErrorState(message: failure.message),
        (_) => LoggedOutState(),
      );
    } else if (event is SignInWithFacebookEvent) {
      yield LoadingState();

      yield* _signInOrSignUpEitherHandler(() => signInWithFacebook(NoParam()));
    } else if (event is CheckLoggedInStateEvent) {
      yield LoadingState();

      final loggedInStateEither = await getLoggedInUserData(NoParam());

      yield loggedInStateEither.fold(
        (failure) => AlertMessageState(message: failure.message),
        (userData) => LoggedInState(user: userData),
      );
    } else if (event is SignInWithEmailAndPasswordEvent) {
      yield LoadingState();

      yield* _signInOrSignUpEitherHandler(
        () => signInWithEmailAndPassword(
          LoginParams(email: event.email, password: event.password),
        ),
      );
    } else if (event is SignUpWithEmailAndPasswordEvent) {
      yield LoadingState();

      loggedUpUsingEmail = true;

      yield* _signInOrSignUpEitherHandler(
        () => signUpWithEmailAndPassword(event.user),
      );
      // if ((await last) is LoggedInState) {
      //   yield SignedUpWithEmailState();
      // }
    } 
  }

  bool loggedUpUsingEmail = false;
  Stream<LoginState> _signInOrSignUpEitherHandler(usecase) async* {
    final signInOrSignUpEither = await usecase();

    yield* signInOrSignUpEither.fold(
      (failure) async* {
        yield ErrorState(message: failure.message);
      },
      (userData) async* {
        if (loggedUpUsingEmail) {
          yield SignedUpWithEmailState();
          loggedUpUsingEmail = false;
        }
        yield LoggedInState(user: userData);
      },
    );
  }
}
