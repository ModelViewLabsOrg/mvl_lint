import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NumberOfParametersRule extends AnalysisRule {
  NumberOfParametersRule({this.maxParameters = 7})
    : super(
        name: 'number_of_parameters',
        description: 'Limit the number of function and method parameters.',
      );

  final int maxParameters;

  static const code = LintCode(
    'number_of_parameters',
    'The maximum allowed number of parameters is {0}. Try reducing the number of parameters.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.number_of_parameters',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addMethodDeclaration(this, _Visitor(this))
      ..addFunctionDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final NumberOfParametersRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final int parameters = node.parameters?.parameters.length ?? 0;
    _reportIfTooMany(node, parameters);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final int parameters = node.functionExpression.parameters?.parameters.length ?? 0;
    _reportIfTooMany(node, parameters);
  }

  void _reportIfTooMany(AnnotatedNode node, int parameters) {
    if (parameters > rule.maxParameters) {
      final int startOffset = node.firstTokenAfterCommentAndMetadata.offset;
      rule.reportAtOffset(
        startOffset,
        node.end - startOffset,
        arguments: [rule.maxParameters],
      );
    }
  }
}
