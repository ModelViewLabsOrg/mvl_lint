import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ExpressionIdentifiersVisitor extends RecursiveAstVisitor<void> {
  final identifiers = <SimpleIdentifier>{};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    identifiers.add(node);
  }
}
