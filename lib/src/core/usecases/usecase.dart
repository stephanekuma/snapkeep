import 'package:snapkeep/src/core/types/index.dart';

abstract class UseCase<T, Param> {
  FutureResult<T> call({required Param param});
}
