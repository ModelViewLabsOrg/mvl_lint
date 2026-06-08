import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidFinalWithGetterRule extends AnalysisRule {
  AvoidFinalWithGetterRule()
    : super(
        name: 'avoid_final_with_getter',
        description: 'Avoid final private fields with getters.',
      );

  static const code = LintCode(
    'avoid_final_with_getter',
    'Avoid final private fields with getters.',
    correctionMessage: 'Use a public final field instead of a private field with a getter.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_final_with_getter',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!node.isGetter) {
      return;
    }

    final ExecutableElement? element = node.declaredFragment?.element;
    if (element == null || element.isAbstract || !element.isPublic) {
      return;
    }

    final int? getterId = _getterReferenceId(node);
    if (getterId == null) {
      return;
    }

    final VariableDeclaration? variable = _findMatchingVariable(node, getterId);
    if (variable != null) {
      rule.reportAtNode(node);
    }
  }

  int? _getterReferenceId(MethodDeclaration getter) {
    final FunctionBody body = getter.body;
    if (body is! ExpressionFunctionBody) {
      return null;
    }

    final Expression expression = body.expression;
    if (expression is! SimpleIdentifier) {
      return null;
    }

    final Element? element = expression.element;
    return switch (element) {
      PropertyAccessorElement(:final variable) => variable.id,
      PropertyInducingElement() => element.id,
      _ => null,
    };
  }

  VariableDeclaration? _findMatchingVariable(
    MethodDeclaration getter,
    int getterId,
  ) {
    VariableDeclaration? result;
    getter.parent?.accept(
      _FieldFinder(getterId, (variable) => result = variable),
    );
    return result;
  }
}

class _FieldFinder extends RecursiveAstVisitor<void> {
  _FieldFinder(this.getterId, this.onFound);

  final int getterId;
  final void Function(VariableDeclaration variable) onFound;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final VariableElement? element = node.declaredFragment?.element;
    if (element != null && element.isPrivate && element.isFinal && element.id == getterId) {
      onFound(node);
    }
    super.visitVariableDeclaration(node);
  }
}
