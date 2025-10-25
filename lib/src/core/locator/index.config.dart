// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:snapkeep/src/core/commons/blocs/theme/theme_bloc.dart' as _i349;
import 'package:snapkeep/src/whatsapp/data/repositories/status_repository_implementation.dart'
    as _i747;
import 'package:snapkeep/src/whatsapp/domain/repositories/status_repository.dart'
    as _i206;
import 'package:snapkeep/src/whatsapp/domain/usecases/load_statuses.dart'
    as _i203;
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart'
    as _i194;
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart'
    as _i335;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i349.ThemeBloc>(() => _i349.ThemeBloc());
    gh.lazySingleton<_i335.StatusCubit>(() => _i335.StatusCubit());
    gh.lazySingleton<_i206.StatusRepository>(
        () => _i747.StatusRepositoryImplementation());
    gh.lazySingleton<_i203.LoadStatuses>(
        () => _i203.LoadStatuses(repository: gh<_i206.StatusRepository>()));
    gh.lazySingleton<_i194.StatusBloc>(
        () => _i194.StatusBloc(loadStatuses: gh<_i203.LoadStatuses>()));
    return this;
  }
}
