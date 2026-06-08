import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

bool isOverride(List<Annotation> metadata) => metadata.any(
  (node) => node.name.name == 'override' && node.atSign.type == TokenType.AT,
);

String humanReadableNodeType(AstNode? node) {
  return switch (node) {
    ClassDeclaration() => 'Class',
    EnumDeclaration() => 'Enum',
    ExtensionDeclaration() => 'Extension',
    MixinDeclaration() => 'Mixin',
    _ => 'Node',
  };
}
