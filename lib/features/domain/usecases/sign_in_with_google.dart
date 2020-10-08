import 'package:GoEXPLORE/core/error/failures.dart';
import 'package:GoEXPLORE/core/usecases/usecase.dart';
import 'package:GoEXPLORE/features/domain/entities/user.dart';
import 'package:GoEXPLORE/features/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

class SignInWithGoogle extends UseCase<User, NoParam> {
  final LoginRepository repository;

  SignInWithGoogle({@required this.repository});

  @override
  Future<Either<Failure, User>> call(NoParam params) {
    return repository.signInWithGoogle();
  }
}
