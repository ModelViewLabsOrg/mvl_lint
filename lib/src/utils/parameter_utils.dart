import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

bool nameConsistsOfUnderscoresOnly(FormalParameter parameter) {
  final Token? paramName = parameter.name;
  if (paramName == null) {
    return false;
  }

  return paramName.lexeme.replaceAll('_', '').isEmpty;
}
