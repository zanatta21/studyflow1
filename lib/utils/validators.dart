class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Informe o e-mail';
    if (!value.contains('@') || !value.contains('.')) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  static String? required(String? value, {String field = 'campo'}) {
    if (value == null || value.trim().isEmpty) return 'Informe o $field';
    return null;
  }
}
