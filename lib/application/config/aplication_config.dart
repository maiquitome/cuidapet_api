import 'package:dotenv/dotenv.dart' show load, env;
import 'package:get_it/get_it.dart';

import './database_connection_configuration.dart';

class ApplicationConfig {
  void loadConfigApplication() async {
    await _loadEnv();
    _loadDatabaseConfig();
  }

  Future<void> _loadEnv() async => load();

  void _loadDatabaseConfig() {
    final databaseConfig = DatabaseConnectionConfiguration(
      host: env['DATABASE_HOST'] ?? env['databaseHost']!,
      user: env['DATABASE_USER'] ?? env['databaseUser']!,
      port: int.tryParse(env['DATABASE_PORT'] ?? env['databaseHost']!) ?? 0,
      password: env['DATABASE_PASSWORD'] ?? env['databasePassword']!,
      databaseName: env['DATABASE_NAME'] ?? env['databaseName']!,
    );
    
    GetIt.I.registerSingleton(databaseConfig);
  }
  
}
