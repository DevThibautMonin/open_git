import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:open_git/shared/core/di/injectable.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
}
