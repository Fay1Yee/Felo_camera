import 'dart:convert';
import 'dart:math';

/// JSON格式修正结果
class JsonFixResult {
  final String fixedJson;
  final List<String> fixedIssues;
  final List<String> remainingErrors;
  final bool isValid;
  final int originalErrorCount;
  final int fixedErrorCount;

  JsonFixResult({
    required this.fixedJson,
    required this.fixedIssues,
    required this.remainingErrors,
    required this.isValid,
    required this.originalErrorCount,
    required this.fixedErrorCount,
  });
}

/// 智能JSON格式修正器
class JsonFormatFixer {
  /// 一键修正JSON格式
  static JsonFixResult autoFixJson(String jsonText) {
    final fixedIssues = <String>[];
    final remainingErrors = <String>[];
    String workingJson = jsonText;
    int originalErrorCount = 0;
    
    // 首先验证原始JSON并统计错误
    final originalErrors = _validateJson(jsonText);
    originalErrorCount = originalErrors.length;
    
    try {
      // 步骤1: 清理和预处理
      final cleanResult = _cleanAndPreprocess(workingJson);
      workingJson = cleanResult['text'];
      fixedIssues.addAll(cleanResult['fixes']);
      
      // 步骤2: 修复常见的JSON语法错误
      final syntaxResult = _fixJsonSyntax(workingJson);
      workingJson = syntaxResult['text'];
      fixedIssues.addAll(syntaxResult['fixes']);
      
      // 步骤3: 修复字符编码和转义问题
      final encodingResult = _fixCharacterEncoding(workingJson);
      workingJson = encodingResult['text'];
      fixedIssues.addAll(encodingResult['fixes']);
      
      // 步骤4: 修复结构问题
      final structureResult = _fixJsonStructure(workingJson);
      workingJson = structureResult['text'];
      fixedIssues.addAll(structureResult['fixes']);
      
      // 步骤5: 格式化和美化
      final formatResult = _formatJson(workingJson);
      workingJson = formatResult['text'];
      fixedIssues.addAll(formatResult['fixes']);
      
      // 最终验证
      final finalErrors = _validateJson(workingJson);
      remainingErrors.addAll(finalErrors);
      
      return JsonFixResult(
        fixedJson: workingJson,
        fixedIssues: fixedIssues,
        remainingErrors: remainingErrors,
        isValid: remainingErrors.isEmpty,
        originalErrorCount: originalErrorCount,
        fixedErrorCount: originalErrorCount - remainingErrors.length,
      );
    } catch (e) {
      remainingErrors.add('修正过程中发生错误: $e');
      return JsonFixResult(
        fixedJson: workingJson,
        fixedIssues: fixedIssues,
        remainingErrors: remainingErrors,
        isValid: false,
        originalErrorCount: originalErrorCount,
        fixedErrorCount: max(0, originalErrorCount - remainingErrors.length),
      );
    }
  }

  /// 清理和预处理
  static Map<String, dynamic> _cleanAndPreprocess(String text) {
    final fixes = <String>[];
    String cleaned = text;
    
    // 移除BOM标记
    if (cleaned.startsWith('\uFEFF')) {
      cleaned = cleaned.substring(1);
      fixes.add('移除BOM标记');
    }
    
    // 移除markdown代码块
    if (cleaned.contains('```json') || cleaned.contains('```')) {
      cleaned = cleaned
          .replaceAll(RegExp(r'^\s*```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^\s*```\s*', multiLine: true), '')
          .replaceAll(RegExp(r'\s*```\s*$', multiLine: true), '');
      fixes.add('移除markdown代码块标记');
    }
    
    // 移除多余的空白字符
    final originalLength = cleaned.length;
    cleaned = cleaned.trim();
    if (cleaned.length != originalLength) {
      fixes.add('移除首尾空白字符');
    }
    
    // 统一换行符
    if (cleaned.contains('\r\n') || cleaned.contains('\r')) {
      cleaned = cleaned.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      fixes.add('统一换行符格式');
    }
    
    return {'text': cleaned, 'fixes': fixes};
  }

  /// 修复JSON语法错误
  static Map<String, dynamic> _fixJsonSyntax(String text) {
    final fixes = <String>[];
    String fixed = text;
    
    // 修复单引号为双引号
    if (fixed.contains("'")) {
      // 智能替换：只替换作为字符串分隔符的单引号
      fixed = _smartQuoteReplacement(fixed);
      fixes.add('修复单引号为双引号');
    }
    
    // 修复属性名没有引号的问题
    final unquotedPropertyPattern = RegExp(r'(\s*)([a-zA-Z_$][a-zA-Z0-9_$]*)\s*:');
    if (unquotedPropertyPattern.hasMatch(fixed)) {
      fixed = fixed.replaceAllMapped(unquotedPropertyPattern, (match) {
        return '${match.group(1)}"${match.group(2)}":';
      });
      fixes.add('为属性名添加引号');
    }
    
    // 修复尾随逗号
    if (fixed.contains(RegExp(r',\s*[}\]]'))) {
      fixed = fixed
          .replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*]'), ']');
      fixes.add('移除尾随逗号');
    }
    
    // 修复缺少逗号的问题
    final missingCommaPattern = RegExp(r'"\s*\n\s*"');
    if (missingCommaPattern.hasMatch(fixed)) {
      fixed = fixed.replaceAll(missingCommaPattern, '",\n"');
      fixes.add('添加缺少的逗号');
    }
    
    // 修复对象/数组之间缺少逗号
    final missingCommaObjectPattern = RegExp(r'}\s*\n\s*{');
    if (missingCommaObjectPattern.hasMatch(fixed)) {
      fixed = fixed.replaceAll(missingCommaObjectPattern, '},\n{');
      fixes.add('添加对象间缺少的逗号');
    }
    
    return {'text': fixed, 'fixes': fixes};
  }

  /// 智能引号替换
  static String _smartQuoteReplacement(String text) {
    final buffer = StringBuffer();
    bool inString = false;
    bool inDoubleQuote = false;
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final prevChar = i > 0 ? text[i - 1] : '';
      final nextChar = i < text.length - 1 ? text[i + 1] : '';
      
      if (char == '"' && prevChar != '\\') {
        inDoubleQuote = !inDoubleQuote;
        inString = inDoubleQuote;
        buffer.write(char);
      } else if (char == "'" && !inDoubleQuote && prevChar != '\\') {
        // 判断是否为字符串分隔符
        if (!inString && (prevChar == ':' || prevChar == '[' || prevChar == ',' || prevChar.trim().isEmpty)) {
          buffer.write('"');
          inString = true;
        } else if (inString && (nextChar == ',' || nextChar == '}' || nextChar == ']' || nextChar.trim().isEmpty)) {
          buffer.write('"');
          inString = false;
        } else {
          buffer.write(char);
        }
      } else {
        buffer.write(char);
      }
    }
    
    return buffer.toString();
  }

  /// 修复字符编码和转义问题
  static Map<String, dynamic> _fixCharacterEncoding(String text) {
    final fixes = <String>[];
    String fixed = text;
    
    // 修复未转义的换行符
    if (fixed.contains(RegExp(r'(?<!\\)"\s*\n\s*[^"]'))) {
      fixed = fixed.replaceAllMapped(RegExp(r'(")(\s*\n\s*)([^"])'), (match) {
        return '${match.group(1)}\\n${match.group(3)}';
      });
      fixes.add('修复字符串中的未转义换行符');
    }
    
    // 修复未转义的引号
    final unescapedQuotePattern = RegExp(r'(?<!\\)"(?=.*".*:)');
    if (unescapedQuotePattern.hasMatch(fixed)) {
      // 这个比较复杂，需要更智能的处理
      fixed = _fixUnescapedQuotes(fixed);
      fixes.add('修复未转义的引号');
    }
    
    // 修复控制字符
    if (fixed.contains(RegExp(r'[\x00-\x1F]'))) {
      fixed = fixed.replaceAllMapped(RegExp(r'[\x00-\x1F]'), (match) {
        final char = match.group(0)!;
        switch (char) {
          case '\t': return '\\t';
          case '\n': return '\\n';
          case '\r': return '\\r';
          case '\b': return '\\b';
          case '\f': return '\\f';
          default: return '\\u${char.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}';
        }
      });
      fixes.add('转义控制字符');
    }
    
    return {'text': fixed, 'fixes': fixes};
  }

  /// 修复未转义的引号
  static String _fixUnescapedQuotes(String text) {
    final lines = text.split('\n');
    final fixedLines = <String>[];
    
    for (final line in lines) {
      String fixedLine = line;
      
      // 在字符串值中查找未转义的引号
      final stringValuePattern = RegExp(r':\s*"([^"]*)"');
      fixedLine = fixedLine.replaceAllMapped(stringValuePattern, (match) {
        final value = match.group(1)!;
        final escapedValue = value.replaceAll('"', '\\"');
        return ': "$escapedValue"';
      });
      
      fixedLines.add(fixedLine);
    }
    
    return fixedLines.join('\n');
  }

  /// 修复JSON结构问题
  static Map<String, dynamic> _fixJsonStructure(String text) {
    final fixes = <String>[];
    String fixed = text;
    
    // 确保JSON以正确的结构开始和结束
    fixed = fixed.trim();
    
    if (!fixed.startsWith('{') && !fixed.startsWith('[')) {
      // 尝试找到JSON部分
      final jsonMatch = RegExp(r'[{\[].*[}\]]', dotAll: true).firstMatch(fixed);
      if (jsonMatch != null) {
        fixed = jsonMatch.group(0)!;
        fixes.add('提取JSON结构部分');
      } else {
        // 如果找不到，尝试包装为对象
        if (fixed.contains(':')) {
          fixed = '{$fixed}';
          fixes.add('包装为JSON对象');
        }
      }
    }
    
    // 检查括号匹配
    final bracketResult = _fixBracketMatching(fixed);
    if (bracketResult['fixed']) {
      fixed = bracketResult['text'];
      fixes.add('修复括号匹配');
    }
    
    return {'text': fixed, 'fixes': fixes};
  }

  /// 修复括号匹配
  static Map<String, dynamic> _fixBracketMatching(String text) {
    final openBrackets = <String>[];
    final closeBrackets = <String>[];
    bool inString = false;
    String prevChar = '';
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      
      if (char == '"' && prevChar != '\\') {
        inString = !inString;
      } else if (!inString) {
        if (char == '{' || char == '[') {
          openBrackets.add(char);
        } else if (char == '}' || char == ']') {
          closeBrackets.add(char);
        }
      }
      
      prevChar = char;
    }
    
    // 计算需要添加的闭合括号
    final missingClosing = <String>[];
    int openCurly = openBrackets.where((b) => b == '{').length;
    int closeCurly = closeBrackets.where((b) => b == '}').length;
    int openSquare = openBrackets.where((b) => b == '[').length;
    int closeSquare = closeBrackets.where((b) => b == ']').length;
    
    for (int i = 0; i < openCurly - closeCurly; i++) {
      missingClosing.add('}');
    }
    for (int i = 0; i < openSquare - closeSquare; i++) {
      missingClosing.add(']');
    }
    
    if (missingClosing.isNotEmpty) {
      return {
        'text': text + missingClosing.join(''),
        'fixed': true,
      };
    }
    
    return {'text': text, 'fixed': false};
  }

  /// 格式化JSON
  static Map<String, dynamic> _formatJson(String text) {
    final fixes = <String>[];
    
    try {
      final decoded = jsonDecode(text);
      final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
      fixes.add('格式化JSON结构');
      return {'text': formatted, 'fixes': fixes};
    } catch (e) {
      // 如果无法解析，返回原文本
      return {'text': text, 'fixes': fixes};
    }
  }

  /// 验证JSON格式（公共方法）
  static List<String> validateJsonFormat(String text) {
    return _validateJson(text);
  }

  /// 验证JSON并返回错误列表
  static List<String> _validateJson(String text) {
    final errors = <String>[];
    
    if (text.trim().isEmpty) {
      errors.add('JSON文本为空');
      return errors;
    }
    
    try {
      jsonDecode(text);
    } catch (e) {
      if (e is FormatException) {
        final message = e.message;
        final offset = e.offset;
        
        if (offset != null && offset < text.length) {
          final lines = text.substring(0, offset).split('\n');
          final lineNumber = lines.length;
          final columnNumber = lines.last.length + 1;
          errors.add('第 $lineNumber 行，第 $columnNumber 列: $message');
        } else {
          errors.add('格式错误: $message');
        }
      } else {
        errors.add('解析错误: $e');
      }
    }
    
    return errors;
  }

  /// 生成修正报告
  static String generateFixReport(JsonFixResult result) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== JSON修正报告 ===');
    buffer.writeln('原始错误数量: ${result.originalErrorCount}');
    buffer.writeln('修正错误数量: ${result.fixedErrorCount}');
    buffer.writeln('剩余错误数量: ${result.remainingErrors.length}');
    buffer.writeln('修正状态: ${result.isValid ? "✅ 成功" : "❌ 部分修正"}');
    buffer.writeln();
    
    if (result.fixedIssues.isNotEmpty) {
      buffer.writeln('已修正的问题:');
      for (int i = 0; i < result.fixedIssues.length; i++) {
        buffer.writeln('${i + 1}. ${result.fixedIssues[i]}');
      }
      buffer.writeln();
    }
    
    if (result.remainingErrors.isNotEmpty) {
      buffer.writeln('剩余错误:');
      for (int i = 0; i < result.remainingErrors.length; i++) {
        buffer.writeln('${i + 1}. ${result.remainingErrors[i]}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('==================');
    
    return buffer.toString();
  }
}