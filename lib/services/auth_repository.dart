import 'package:firebase_auth/firebase_auth.dart';

/// Erro de autenticação com mensagem já traduzida para mostrar na UI.
class AuthException implements Exception {
  const AuthException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Traduz um código de erro do FirebaseAuth para uma mensagem em português.
/// Função pura (sem depender do Firebase em si) para ficar fácil de testar.
String mensagemDeErroAuth(String codigo) => switch (codigo) {
  'email-already-in-use' => 'Este e-mail já está cadastrado.',
  'weak-password' => 'A senha precisa ter pelo menos 6 caracteres.',
  'invalid-email' => 'E-mail inválido.',
  'user-not-found' || 'wrong-password' || 'invalid-credential' =>
    'E-mail ou senha incorretos.',
  'user-disabled' => 'Esta conta foi desativada.',
  'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
  'network-request-failed' => 'Sem conexão com a internet.',
  _ => 'Não foi possível completar a operação. Tente novamente.',
};

/// Conta da usuária via Firebase Authentication (e-mail e senha).
class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get mudancasDeUsuario => _auth.authStateChanges();

  User? get usuarioAtual => _auth.currentUser;

  Future<void> cadastrar({required String email, required String senha}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensagemDeErroAuth(e.code));
    }
  }

  Future<void> entrar({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensagemDeErroAuth(e.code));
    }
  }

  Future<void> sair() => _auth.signOut();

  Future<void> redefinirSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensagemDeErroAuth(e.code));
    }
  }
}
