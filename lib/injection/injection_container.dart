import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:split_it/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:split_it/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:split_it/features/auth/domain/repositories/auth_repository.dart';
import 'package:split_it/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:split_it/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:split_it/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:split_it/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:split_it/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/network/network_info_impl.dart';
import '../core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => GoogleSignIn.instance);


  // core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()),);

  // auth
  // datasource
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // repo
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl(), networkInfo: sl())
  );

  // usecases
  sl.registerLazySingleton(() => SignInWithEmailUsecase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  await sl<GoogleSignIn>().initialize();
  
}