import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';
import 'package:mvl_lint/src/utils/node_utils.dart';
import 'package:mvl_lint/src/utils/parameter_utils.dart';

class AvoidUnusedParametersRule extends AnalysisRule {
  AvoidUnusedParametersRule()
    : super(
        name: 'avoid_unused_parameters',
        description: 'Avoid unused function, method, and constructor parameters.',
      );

  static const code = LintCode(
    'avoid_unused_parameters',
    'Parameter is unused.',
    correctionMessage: 'Remove the parameter or prefix it with underscores.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_unused_parameters',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addConstructorDeclaration(this, _Visitor(this))
      ..addMethodDeclaration(this, _Visitor(this))
      ..addFunctionExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final AstNode? parent = node.parent;
    final FormalParameterList parameters = node.parameters;

    if (parent is ClassDeclaration && parent.abstractKeyword != null ||
        node.externalKeyword != null ||
        parameters.parameters.isEmpty) {
      return;
    }

    _getUnusedParameters(
      node.body,
      parameters.parameters,
      initializers: node.initializers,
    ).whereNot(nameConsistsOfUnderscoresOnly).forEach(rule.reportAtNode);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final AstNode? parent = node.parent;
    final FormalParameterList? parameters = node.parameters;

    if (parent is ClassDeclaration && parent.abstractKeyword != null ||
        node.isAbstract ||
        node.externalKeyword != null ||
        parameters == null ||
        parameters.parameters.isEmpty) {
      return;
    }

    if (!isOverride(node.metadata) && !_usedAsTearOff(node)) {
      _filterOutUnderscoresAndNamed(node.body, parameters.parameters).forEach(rule.reportAtNode);
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    final FormalParameterList? params = node.parameters;
    if (params == null) {
      return;
    }

    _filterOutUnderscoresAndNamed(node.body, params.parameters).forEach(rule.reportAtNode);
  }

  Iterable<FormalParameter> _filterOutUnderscoresAndNamed(
    AstNode body,
    Iterable<FormalParameter> parameters,
  ) {
    return _getUnusedParameters(
      body,
      parameters,
    ).whereNot(nameConsistsOfUnderscoresOnly).where((param) => !param.isNamed);
  }

  Set<FormalParameter> _getUnusedParameters(
    AstNode body,
    Iterable<FormalParameter> parameters, {
    NodeList<AstNode>? initializers,
  }) {
    final result = <FormalParameter>{};
    final visitor = _IdentifiersVisitor();
    body.visitChildren(visitor);
    initializers?.accept(visitor);

    for (final parameter in parameters) {
      final Token? name = parameter.name;
      final bool isPresentInAll = visitor.elements.contains(
        parameter.declaredFragment?.element.baseElement.nonSynthetic,
      );

      var isFieldFormalParameter = parameter is FieldFormalParameter;
      var isSuperFormalParameter = parameter is SuperFormalParameter;

      if (!isFieldFormalParameter && !isSuperFormalParameter) {
        final String source = parameter.toSource();
        isFieldFormalParameter = source.contains('this.');
        isSuperFormalParameter = source.contains('super.');
      }

      if (name != null && !isPresentInAll && !isFieldFormalParameter && !isSuperFormalParameter) {
        result.add(parameter);
      }
    }

    return result;
  }

  bool _usedAsTearOff(MethodDeclaration node) {
    final String name = node.name.lexeme;
    if (!Identifier.isPrivateName(name)) {
      return false;
    }

    final visitor = _InvocationsVisitor(name);
    node.root.visitChildren(visitor);
    return visitor.hasTearOffInvocations;
  }
}

class _IdentifiersVisitor extends RecursiveAstVisitor<void> {
  final elements = <Element>{};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final Element? element = node.element;
    if (element != null) {
      elements.add(element);
    }
    super.visitSimpleIdentifier(node);
  }
}

class _InvocationsVisitor extends RecursiveAstVisitor<void> {
  _InvocationsVisitor(this.methodName);

  final String methodName;
  var hasTearOffInvocations = false;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == methodName && node.element is MethodElement && node.parent is ArgumentList) {
      hasTearOffInvocations = true;
    }
    super.visitSimpleIdentifier(node);
  }
}
