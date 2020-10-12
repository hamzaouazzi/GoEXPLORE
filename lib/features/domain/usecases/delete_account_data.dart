import 'package:GoEXPLORE/core/error/failures.dart';
import 'package:GoEXPLORE/core/usecases/usecase.dart';
import 'package:GoEXPLORE/features/domain/entities/user.dart';
import 'package:GoEXPLORE/features/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

class DeleteAccountData extends UseCase<String, User> {
  final LoginRepository repository;

  DeleteAccountData({@required this.repository});

  @override
  Future<Either<Failure, String>> call(User user) {
    return repository.deleteAccount(user);
  }
}
