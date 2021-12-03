import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:cuidapet_api_dart/application/middlewares/cors/cors_middlewares.dart';
import 'package:cuidapet_api_dart/application/config/aplication_config.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
// const _hostname = 'localhost';

// para responder tanto pelo IP como pelo LOCALHOST
const _hostname = '0.0.0.0';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '4000';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  final router = Router();
  final appConfig = ApplicationConfig();
  appConfig.loadConfigApplication(router);

  router.get('/hello', (shelf.Request request) {
    return shelf.Response.ok('Hello Maiqui');
  });

  var handler = const shelf.Pipeline()
      .addMiddleware(CorsMiddlewares().handler)
      .addMiddleware(shelf.logRequests())
      .addHandler(router);

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}
