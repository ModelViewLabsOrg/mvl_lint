import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';

class NoMagicNumberRule extends AnalysisRule {
  NoMagicNumberRule({
    this.allowedNumbers = const {},
    this.allowedInWidgetParams = true,
  }) : super(
         name: 'no_magic_number',
         description: 'Avoid magic numbers in code.',
       );

  final Set<num> allowedNumbers;
  final bool allowedInWidgetParams;

  static const code = LintCode(
    'no_magic_number',
    'Avoid using magic numbers. Extract them to named constants or variables.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.no_magic_number',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addDoubleLiteral(this, _Visitor(this))
      ..addIntegerLiteral(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final NoMagicNumberRule rule;

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _checkLiteral(node, node.value);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _checkLiteral(node, node.value);
  }

  void _checkLiteral(Literal literal, num? value) {
    if (value == null || rule.allowedNumbers.contains(value)) {
      return;
    }
    if (!_isNotInsideVariable(literal)) {
      return;
    }
    if (!_isNotInsideCollectionLiteral(literal)) {
      return;
    }
    if (!_isNotInsideConstMap(literal)) {
      return;
    }
    if (!_isNotInsideConstConstructor(literal)) {
      return;
    }
    if (!_isNotInDateTime(literal)) {
      return;
    }
    if (!_isNotInsideIndexExpression(literal)) {
      return;
    }
    if (!_isNotInsideEnumConstantArguments(literal)) {
      return;
    }
    if (!_isNotDefaultValue(literal)) {
      return;
    }
    if (!_isNotInConstructorInitializer(literal)) {
      return;
    }
    if (!_isNotWidgetParameter(literal)) {
      return;
    }

    rule.reportAtNode(literal);
  }

  bool _isNotInsideVariable(Literal literal) {
    var isInstanceCreationExpression = false;
    return literal.thisOrAncestorMatching((ancestor) {
          if (ancestor is InstanceCreationExpression) {
            isInstanceCreationExpression = true;
          }
          if (isInstanceCreationExpression) {
            return false;
          }
          return ancestor is VariableDeclaration;
        }) ==
        null;
  }

  bool _isNotInDateTime(Literal literal) =>
      literal.thisOrAncestorMatching(
        (ancestor) =>
            ancestor is InstanceCreationExpression &&
            ancestor.staticType?.getDisplayString() == 'DateTime',
      ) ==
      null;

  bool _isNotInsideEnumConstantArguments(Literal literal) =>
      literal.thisOrAncestorMatching(
        (ancestor) => ancestor is EnumConstantArguments,
      ) ==
      null;

  bool _isNotInsideCollectionLiteral(Literal literal) => literal.parent is! TypedLiteral;

  bool _isNotInsideConstMap(Literal literal) {
    final AstNode? grandParent = literal.parent?.parent;
    return !(grandParent is SetOrMapLiteral && grandParent.isConst);
  }

  bool _isNotInsideConstConstructor(Literal literal) =>
      literal.thisOrAncestorMatching(
        (ancestor) => ancestor is InstanceCreationExpression && ancestor.isConst,
      ) ==
      null;

  bool _isNotInsideIndexExpression(Literal literal) => literal.parent is! IndexExpression;

  bool _isNotDefaultValue(Literal literal) =>
      literal.thisOrAncestorOfType<FormalParameterDefaultClause>() == null;

  bool _isNotInConstructorInitializer(Literal literal) =>
      literal.thisOrAncestorOfType<ConstructorInitializer>() == null;

  bool _isNotWidgetParameter(Literal literal) {
    if (!rule.allowedInWidgetParams) {
      return true;
    }

    final AstNode? widgetCreationExpression = literal.thisOrAncestorMatching(
      _isWidgetCreationExpression,
    );
    return widgetCreationExpression == null;
  }

  bool _isWidgetCreationExpression(AstNode node) {
    if (node is! InstanceCreationExpression) {
      return false;
    }

    final DartType? staticType = node.staticType;
    if (staticType is! InterfaceType) {
      return false;
    }

    final InterfaceType? widgetSupertype = staticType.allSupertypes.firstWhereOrNull(
      (supertype) => supertype.getDisplayString() == 'Widget',
    );
    return widgetSupertype != null;
  }
}
