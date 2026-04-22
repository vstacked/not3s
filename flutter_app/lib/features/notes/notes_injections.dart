import 'package:not3s/core/network/dio_network.dart';
import 'package:not3s/core/utils/injections.dart';
import 'package:not3s/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:not3s/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:not3s/features/notes/domain/repositories/notes_repository.dart';
import 'package:not3s/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:not3s/features/notes/presentation/bloc/notes_bloc.dart';

Future<void> initNotesInjections() async {
  // Data source
  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(dio: DioNetwork.dio),
  );

  // Repository
  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(remoteDataSource: sl<NotesRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotesUseCase(sl<NotesRepository>()));
  sl.registerLazySingleton(() => CreateNoteUseCase(sl<NotesRepository>()));
  sl.registerLazySingleton(() => UpdateNoteUseCase(sl<NotesRepository>()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl<NotesRepository>()));

  // BLoC — factory so each NotesPage gets a fresh instance
  sl.registerFactory(
    () => NotesBloc(
      getNotesUseCase: sl<GetNotesUseCase>(),
      createNoteUseCase: sl<CreateNoteUseCase>(),
      updateNoteUseCase: sl<UpdateNoteUseCase>(),
      deleteNoteUseCase: sl<DeleteNoteUseCase>(),
    ),
  );
}
