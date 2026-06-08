import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

const _todoComment = 'TODO';

class NoEmptyBlockRule extends AnalysisRule {
  NoEmptyBlockRule({this.allowWithComments = false})
    : super(
        name: 'no_empty_block',
        description: 'Forbid empty code blocks.',
      );

  final bool allowWithComments;

  static const code = LintCode(
    'no_empty_block',
    'Block is empty. Empty blocks are often indicators of missing code.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.no_empty_block',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addBlock(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final NoEmptyBlockRule rule;

  @override
  void visitBlock(Block node) {
    if (node.statements.isNotEmpty) {
      return;
    }
    if (rule.allowWithComments && _isPrecedingCommentAny(node)) {
      return;
    }
    if (_isPrecedingCommentToDo(node)) {
      return;
    }

    rule.reportAtNode(node);
  }

  bool _isPrecedingCommentToDo(Block node) =>
      node.endToken.precedingComments?.lexeme.contains(_todoComment) ?? false;

  bool _isPrecedingCommentAny(Block node) => node.endToken.precedingComments != null;
}
