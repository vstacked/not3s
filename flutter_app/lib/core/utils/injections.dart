import 'package:get_it/get_it.dart';
import 'package:not3s/core/network/dio_network.dart';
import 'package:not3s/shared/app_injections.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  await initAppInjections();
  DioNetwork.initDio();
}
