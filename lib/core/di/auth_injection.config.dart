// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:vet_care/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i909;
import 'package:vet_care/features/auth/data/repositories/auth_repository.dart'
    as _i65;
import 'package:vet_care/features/auth/presentation/cubit/auth_cubit.dart'
    as _i302;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i909.AuthRemoteDataSource>(
      () => _i909.AuthRemoteDataSource(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i65.AuthRepository>(
      () => _i65.AuthRepository(gh<_i909.AuthRemoteDataSource>()),
    );
    gh.factory<_i302.AuthCubit>(
      () => _i302.AuthCubit(gh<_i65.AuthRepository>(), gh<_i59.FirebaseAuth>()),
    );
    return this;
  }
}
