import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';

class AvoidUnrelatedTypeAssertionsRule extends AnalysisRule {
  AvoidUnrelatedTypeAssertionsRule()
    : super(
        name: 'avoid_unrelated_type_assertions',
        description: 'Avoid unrelated is assertions.',
      );

  static const code = LintCode(
    'avoid_unrelated_type_assertions',
    'Avoid unrelated "is" assertion. The result is always "{0}".',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_unrelated_type_assertions',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addIsExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitIsExpression(IsExpression node) {
    final DartType? castedType = node.type.type;
    if (castedType is TypeParameterType) {
      return;
    }

    final DartType? objectType = node.expression.staticType;
    if (_isUnrelatedTypeCheck(objectType, castedType)) {
      rule.reportAtNode(
        node,
        arguments: [if (node.notOperator == null) 'false' else 'true'],
      );
    }
  }

  bool _isUnrelatedTypeCheck(DartType? objectType, DartType? castedType) {
    if (objectType == null || castedType == null) {
      return false;
    }

    if (objectType is DynamicType || castedType is DynamicType) {
      return false;
    }

    if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
      return false;
    }

    final DartType? objectCastedType = _foundCastedTypeInObjectTypeHierarchy(
      objectType,
      castedType,
    );
    final DartType? castedObjectType = _foundCastedTypeInObjectTypeHierarchy(
      castedType,
      objectType,
    );
    if (objectCastedType == null && castedObjectType == null) {
      return true;
    }

    if (objectCastedType == null || castedObjectType == null) {
      return false;
    }

    if (_checkGenerics(objectCastedType, castedType) &&
        _checkGenerics(castedObjectType, objectType)) {
      return true;
    }

    return false;
  }

  DartType? _foundCastedTypeInObjectTypeHierarchy(
    DartType objectType,
    DartType castedType,
  ) {
    if (_isFutureOrAndFuture(objectType, castedType)) {
      return objectType;
    }

    final DartType correctObjectType = objectType is InterfaceType && objectType.isDartAsyncFutureOr
        ? objectType.typeArguments.first
        : objectType;

    if (correctObjectType.element == castedType.element ||
        castedType is DynamicType ||
        correctObjectType is DynamicType ||
        _isObjectAndEnum(correctObjectType, castedType)) {
      return correctObjectType;
    }

    if (correctObjectType is InterfaceType) {
      return correctObjectType.allSupertypes.firstWhereOrNull(
        (value) => value.element == castedType.element,
      );
    }

    return null;
  }

  bool _checkGenerics(DartType objectType, DartType castedType) {
    if (objectType is DynamicType || castedType is DynamicType) {
      return false;
    }

    if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
      return false;
    }

    final int length = objectType.typeArguments.length;
    if (length != castedType.typeArguments.length) {
      return false;
    }

    for (var argumentIndex = 0; argumentIndex < length; argumentIndex++) {
      final DartType objectGenericType = objectType.typeArguments[argumentIndex];
      final DartType castedGenericType = castedType.typeArguments[argumentIndex];

      if (_isUnrelatedTypeCheck(objectGenericType, castedGenericType) &&
          _isUnrelatedTypeCheck(castedGenericType, objectGenericType)) {
        return true;
      }
    }

    return false;
  }

  bool _isFutureOrAndFuture(DartType objectType, DartType castedType) =>
      objectType.isDartAsyncFutureOr && castedType.isDartAsyncFuture;

  bool _isObjectAndEnum(DartType objectType, DartType castedType) =>
      objectType.isDartCoreObject && castedType.element?.kind == ElementKind.ENUM;
}
