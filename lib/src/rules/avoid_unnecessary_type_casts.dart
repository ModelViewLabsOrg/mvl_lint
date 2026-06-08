import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:mvl_lint/src/utils/typecast_utils.dart';

class AvoidUnnecessaryTypeCastsRule extends AnalysisRule {
  AvoidUnnecessaryTypeCastsRule()
    : super(
        name: 'avoid_unnecessary_type_casts',
        description: 'Avoid unnecessary usage of the as operator.',
      );

  static const code = LintCode(
    'avoid_unnecessary_type_casts',
    'Avoid unnecessary usage of as operator.',
    correctionMessage: 'Remove the unnecessary type cast.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_unnecessary_type_casts',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addAsExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitAsExpression(AsExpression node) {
    final DartType? objectType = node.expression.staticType;
    final DartType? castedType = node.type.type;

    if (objectType == null || castedType == null) {
      return;
    }

    final typeCast = TypeCast(source: objectType, target: castedType);
    if (typeCast.isUnnecessaryTypeCheck) {
      rule.reportAtNode(node);
    }
  }
}
