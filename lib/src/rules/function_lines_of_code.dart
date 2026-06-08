import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';

class FunctionLinesOfCodeRule extends AnalysisRule {
  FunctionLinesOfCodeRule({this.maxLines = 200})
    : super(
        name: 'function_lines_of_code',
        description: 'Limit meaningful lines of code inside functions.',
      );

  final int maxLines;

  static const code = LintCode(
    'function_lines_of_code',
    'The maximum allowed number of lines is {0}. Try splitting this function into smaller parts.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.function_lines_of_code',
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
      ..addFunctionDeclaration(this, _Visitor(this))
      ..addFunctionExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final FunctionLinesOfCodeRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkNode(node, node.body);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkNode(node, node.functionExpression.body);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.parent is FunctionDeclaration) {
      return;
    }
    _checkNode(node, node.body);
  }

  void _checkNode(AstNode node, FunctionBody body) {
    final LineInfo? lineInfo = node.thisOrAncestorOfType<CompilationUnit>()?.lineInfo;
    if (lineInfo == null) {
      return;
    }
    final visitor = _FunctionLinesOfCodeVisitor(lineInfo);
    body.accept(visitor);

    if (visitor.linesWithCode.length > rule.maxLines) {
      if (node is AnnotatedNode) {
        final int startOffset = node.firstTokenAfterCommentAndMetadata.offset;
        final int lengthDifference = startOffset - node.offset;
        rule.reportAtOffset(
          startOffset,
          node.length - lengthDifference,
          arguments: [rule.maxLines],
        );
      } else {
        rule.reportAtNode(node, arguments: [rule.maxLines]);
      }
    }
  }
}

class _FunctionLinesOfCodeVisitor extends RecursiveAstVisitor<void> {
  _FunctionLinesOfCodeVisitor(this.lineInfo);

  final LineInfo lineInfo;
  final linesWithCode = <int>{};

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _collectFunctionBodyData(
      node.block.leftBracket.next,
      node.block.rightBracket,
    );
    super.visitBlockFunctionBody(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _collectFunctionBodyData(
      node.expression.beginToken.previous,
      node.expression.endToken.next,
    );
    super.visitExpressionFunctionBody(node);
  }

  void _collectFunctionBodyData(Token? firstToken, Token? lastToken) {
    var token = firstToken;
    while (token != lastToken && token != null) {
      if (!token.isSynthetic) {
        linesWithCode.add(lineInfo.getLocation(token.offset).lineNumber);
      }
      token = token.next;
    }
  }
}
