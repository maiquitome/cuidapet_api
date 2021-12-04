import 'package:dotenv/dotenv.dart' show env;
import 'package:jaguar_jwt/jaguar_jwt.dart';

class JwtHelper {
  // env['jwtSecret']! forçar que nunca vai ser nulo
  static final String _jwtSecret = env['JWT_SECRET'] ?? env['jwtSecret']!;

  // construtor privado (não deixa a classe ser instanciada)
  JwtHelper._();

  static String generateJWT(int userId, int? supplierId) {
    final JwtClaim claimSet = JwtClaim(
        issuer: 'cuidapet',
        subject: userId.toString(),
        expiry: DateTime.now().add(const Duration(days: 1)),
        notBefore: DateTime.now(),
        issuedAt: DateTime.now(),
        otherClaims: <String, dynamic>{'supplier': supplierId},
        maxAge: const Duration(days: 1));

    return 'Bearer ${issueJwtHS256(claimSet, _jwtSecret)}';
  }

  static JwtClaim getClaims(String token) {
    return verifyJwtHS256Signature(token, _jwtSecret);
  }
}