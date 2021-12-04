import 'dart:io';

import 'package:shelf/src/response.dart';
import 'package:shelf/src/request.dart';

import '../middlewares.dart';

class CorsMiddlewares extends Middlewares {
  // ---------------------
  // HEADERS DE SEGURANÇA:
  // ---------------------
  final Map<String, String> headers = <String, String>{
    // -----------------------------------------
    // Essa checagem é feita somente no browser.
    // -----------------------------------------

    // Qual a origem que eu aceito receber requisições.
    'Access-Control-Allow-Origin': '*',
    // Quais os metódos permitidos para essas url's
    'Access-Control-Allow-Methods': 'GET, POST, PATCH, PUT, DELETE, OPTIONS',
    // Quais os parametros que eu aceito receber
    'Access-Control-Allow-Header':
        '${HttpHeaders.contentTypeHeader}, ${HttpHeaders.authorizationHeader}'
  };

  @override
  Future<Response> execute(Request request) async {
    // print('Iniciando CrossDomain');

    // se for OPTIONS já retorna a resposta
    if (request.method == 'OPTIONS') {
      // print('Retornando Headers do CrossDomain');

      return Response(HttpStatus.ok, headers: headers);
    }

    // print('Executando função CrossDomain');

    // -------------------------------------------------------------------
    //       PARA OS OUTROS MÉTODOS: 'GET, POST, PATCH, PUT, DELETE'
    // -------------------------------------------------------------------

    // executa a requisição
    final Response response = await innerHandler(request);

    // print('Respondendo para o cliente CrossDomain');

    // Pega os headers que já tem e adiciona os headers de segurança.
    return response.change(headers: headers);
  }
}
