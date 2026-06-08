import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:mvl_lint/src/utils/typecast_utils.dart';
import 'package:mvl_lint/src/utils/types_utils.dart';

const _operatorIsName = 'is';
const _whereTypeMethodName = 'whereType';

class AvoidUnnecessaryTypeAssertionsRule extends MultiAnalysisRule {
  AvoidUnnecessaryTypeAssertionsRule()
    : super(
        name: 'avoid_unnecessary_type_assertions',
        description: 'Avoid unnecessary is and whereType checks.',
      );

  static const isCode = LintCode(
    'avoid_unnecessary_type_assertions',
    "Unnecessary usage of the '$_operatorIsName' operator.",
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_unnecessary_type_assertions.is',
  );

  static const whereTypeCode = LintCode(
    'avoid_unnecessary_type_assertions',
    "Unnecessary usage of the '$_whereTypeMethodName' method.",
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_unnecessary_type_assertions.whereType',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [isCode, whereTypeCode];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addIsExpression(this, _IsVisitor(this))
      ..addMethodInvocation(this, _WhereTypeVisitor(this));
  }
}

class _IsVisitor extends SimpleAstVisitor<void> {
  _IsVisitor(this.rule);
  final AvoidUnnecessaryTypeAssertionsRule rule;

  @override
  void visitIsExpression(IsExpression node) {
    final DartType? objectType = node.expression.staticType;
    final DartType? castedType = node.type.type;

    if (objectType == null || castedType == null) {
      return;
    }

    final typeCast = TypeCast(
      source: objectType,
      target: castedType,
      isReversed: node.notOperator != null,
    );

    if (typeCast.isUnnecessaryTypeCheck) {
      rule.reportAtNode(node, diagnosticCode: AvoidUnnecessaryTypeAssertionsRule.isCode);
    }
  }
}

class _WhereTypeVisitor extends SimpleAstVisitor<void> {
  _WhereTypeVisitor(this.rule);
  final AvoidUnnecessaryTypeAssertionsRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != _whereTypeMethodName) {
      return;
    }

    final DartType? targetType = node.target?.staticType;
    final DartType? realTargetType = node.realTarget?.staticType;
    final List<dynamic> arguments = node.typeArguments?.arguments ?? const [];

    if (targetType is! ParameterizedType || !isIterable(realTargetType) || arguments.isEmpty) {
      return;
    }

    final DartType objectType = targetType.typeArguments.first;
    final dynamic firstArgument = arguments.first;
    if (firstArgument is! NamedType) {
      return;
    }
    final DartType? castedType = firstArgument.type;
    if (castedType == null) {
      return;
    }

    final typeCast = TypeCast(source: objectType, target: castedType);
    if (typeCast.isUnnecessaryTypeCheck) {
      rule.reportAtNode(
        node,
        diagnosticCode: AvoidUnnecessaryTypeAssertionsRule.whereTypeCode,
      );
    }
  }
}
