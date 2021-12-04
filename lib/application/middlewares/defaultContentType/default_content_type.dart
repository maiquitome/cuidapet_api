import 'package:shelf/src/response.dart';
import 'package:shelf/src/request.dart';

import '../middlewares.dart';

class DefaultContentType extends Middlewares {
  DefaultContentType(this.contentType);

  final String contentType;

  @override
  Future<Response> execute(Request request) async {
    final Response response = await innerHandler(request);

    return response.change(
      headers: <String, String>{'content-type': contentType},
    );
  }
}
