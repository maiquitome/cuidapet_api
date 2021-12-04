import 'dart:convert';

import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/src/response.dart';
import 'package:shelf/src/request.dart';

import '/application/helpers/jwt_helper.dart';
import '/application/logger/i_logger.dart';
import '../middlewares.dart';
import './security_skip_url.dart';

class SecurityMiddleware extends Middlewares {
  SecurityMiddleware(this.log);

  final ILogger log;
  final List<SecuritySkipUrl> skypUrl = <SecuritySkipUrl>[
    SecuritySkipUrl(url: '/auth/register', method: 'POST'),
    SecuritySkipUrl(url: '/auth/', method: 'POST'), // login
    SecuritySkipUrl(url: '/suppliers/user', method: 'GET'),
    SecuritySkipUrl(url: '/suppliers/user', method: 'POST'),
    SecuritySkipUrl(url: '/health', method: 'GET'),
  ];

  @override
  Future<Response> execute(Request request) async {
    try {
      final bool _isUrlToEscape = skypUrl.contains(
        SecuritySkipUrl(
          url: '/${request.url.path}',
          method: request.method,
        ),
      );

      // Se a url tá liberada segue o fluxo, não precisa de validação.
      if (_isUrlToEscape) {
        return innerHandler(request);
      }

      // --------------------
      //      VALIDAÇÕES
      // --------------------

      // Pegar o header da minha requisição.
      // Busca do token.
      final String? authHeader = request.headers['Authorization'];

      // Se for vazio então acesso negado
      if (authHeader == null || authHeader.isEmpty) {
        throw JwtException.invalidToken;
      }

      // O TOKEN VEM SEMPRE ASSIM:
      //
      // 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
      // .eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ
      // .SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'

      // O pedaço 'Bearer ' não precisamos, por isso usamos o split
      final List<String> authHeaderContent = authHeader.split(' ');

      if (authHeaderContent[0] != 'Bearer') {
        throw JwtException.invalidToken;
      }

      final String authorizationToken = authHeaderContent[1];

      // DESCRIPTOGRAFAR
      // PEGA O PAYLOAD
      // por exemplo:
      // {
      //   "sub": "1234567890", -> userId
      //   "name": "John Doe",
      //   "iat": 1516239022,
      //   e outras coisas...
      // }
      final JwtClaim claims = JwtHelper.getClaims(authorizationToken);

      if (request.url.path != 'auth/refresh') {
        // ----------
        // FORMAS DE VALIDAÇÃO DO TOKEN:
        // ----------
        // O token pode estar inválido pois...
        //   * a chave está errada;
        //   * o hash está errado;
        //   * ou ele está expirado.
        claims.validate();
      }

      // Pegar os valores e deixar disponivel pro serviço que vai ser chamado.
      final Map<String, dynamic> claimsMap = claims.toJson();

      final String? userId = claimsMap['sub'];
      final String? supplierId = claimsMap['supplier']; // custom param

      if (userId == null) {
        throw JwtException.invalidToken;
      }

      // Headers que vão ser adicionados na request.
      final Map<String, dynamic> securityHeaders = <String, dynamic>{
        'user': userId,
        'access_token': authorizationToken,
        // O fornecedor não é obrigatório:
        'supplier': supplierId != null ? '$supplierId' : null
      };

      // Adicionar o token dentro da request,
      // alterando os headers da request.
      return innerHandler(request.change(headers: securityHeaders));
    } on JwtException catch (e, s) {
      log.error('Error validating JWT token', e, s);
      return Response.forbidden(jsonEncode(<Object?>{}));
    } catch (e, s) {
      log.error('Internal Server Error', e, s);
      return Response.forbidden(jsonEncode(<Object?>{}));
    }
  }
}
