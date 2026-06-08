import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:mvl_lint/src/utils/node_utils.dart';
import 'package:path/path.dart' as p;

class PreferMatchFileNameRule extends AnalysisRule {
  PreferMatchFileNameRule()
    : super(
        name: 'prefer_match_file_name',
        description: 'File name should match the first declared public element.',
      );

  static const code = LintCode(
    'prefer_match_file_name',
    'File name does not match with first {0} name.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.prefer_match_file_name',
  );

  static final _onlySymbolsRegex = RegExp('[^a-zA-Z0-9]');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _Visitor(this, context));
  }
}

class _DeclarationInfo {
  _DeclarationInfo({required this.token, required this.parent});

  final Token token;
  final AstNode parent;
}

class _Visitor extends RecursiveAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final PreferMatchFileNameRule rule;
  final RuleContext context;
  final _declarations = <_DeclarationInfo>[];

  @override
  void visitCompilationUnit(CompilationUnit node) {
    _declarations.clear();
    super.visitCompilationUnit(node);

    if (_declarations.isEmpty) {
      return;
    }

    final List<_DeclarationInfo> sorted = [..._declarations]
      ..sort((a, b) {
        final bool isAPrivate = Identifier.isPrivateName(a.token.lexeme);
        final bool isBPrivate = Identifier.isPrivateName(b.token.lexeme);
        if (!isAPrivate && isBPrivate) {
          return -1;
        }
        if (isAPrivate && !isBPrivate) {
          return 1;
        }
        return a.token.offset.compareTo(b.token.offset);
      });

    final _DeclarationInfo firstDeclaration = sorted.first;
    final String? filePath = context.currentUnit?.file.path;
    if (filePath == null) {
      return;
    }

    if (_doNormalizedNamesMatch(filePath, firstDeclaration.token.lexeme)) {
      return;
    }

    final String nodeType = humanReadableNodeType(firstDeclaration.parent).toLowerCase();
    rule.reportAtToken(
      firstDeclaration.token,
      arguments: [nodeType],
    );
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _declarations.add(
      _DeclarationInfo(token: node.namePart.typeName, parent: node),
    );
    super.visitClassDeclaration(node);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    final Token? name = node.name;
    if (name != null) {
      _declarations.add(_DeclarationInfo(token: name, parent: node));
    }
    super.visitExtensionDeclaration(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _declarations.add(_DeclarationInfo(token: node.name, parent: node));
    super.visitMixinDeclaration(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _declarations.add(
      _DeclarationInfo(token: node.namePart.typeName, parent: node),
    );
    super.visitEnumDeclaration(node);
  }

  bool _doNormalizedNamesMatch(String path, String identifierName) {
    final String fileName = p
        .basename(path)
        .split('.')
        .first
        .replaceAll(PreferMatchFileNameRule._onlySymbolsRegex, '')
        .toLowerCase();
    final String dartIdentifier = identifierName
        .replaceAll(PreferMatchFileNameRule._onlySymbolsRegex, '')
        .toLowerCase();
    return fileName == dartIdentifier;
  }
}
