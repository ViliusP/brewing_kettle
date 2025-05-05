import 'package:petitparser/definition.dart';
import 'package:petitparser/parser.dart';

import 'encoding.dart';
import 'types.dart';

/// JSON grammar definition.
class JsonDefinition extends GrammarDefinition<JSON> {
  @override
  Parser<JSON> start() => ref0(value).end();

  Parser<JSON> value([bool isKey = false]) =>
      [
        ref0(object),
        // ref0(array),
        ref1(stringToken, isKey),
        ref(numberToken),
        ref0(trueToken),
        ref0(falseToken),
        ref0(nullToken),
        failure('value expected'),
      ].toChoiceParser();

  Parser<List<JsonToken>> object() => seq5(
    char('{'),
    ref0(whitespaceSeq),
    ref0(objectElements),
    ref0(whitespaceSeq),
    char('}'),
  ).map5((start, ws1, elements, ws2, end) {
    return [
      JsonToken(value: start, type: JsonTokenType.objectBracket),
      ws1,
      ...elements,
      ws2,
      JsonToken(value: end, type: JsonTokenType.objectBracket),
    ].where((token) => token.value.isNotEmpty).toList();
  });

  Parser<List<JsonToken>> objectElements() => ref0(objectElement)
      .starSeparated(ref0(commaSeparator))
      .map(
        (result) => [
          for (var i = 0; i < result.elements.length; i++) ...[
            ...result.elements[i],
            if (i < result.separators.length) ...result.separators[i],
          ],
        ],
      );

  Parser<List<JsonToken>> commaSeparator() =>
      seq3(ref0(whitespaceSeq), char(','), ref0(whitespaceSeq)).map3(
        (ws1, comma, ws2) =>
            [
              ws1,
              JsonToken(value: comma, type: JsonTokenType.comma),
              ws2,
            ].where((token) => token.value.isNotEmpty).toList(),
      );

  Parser<List<JsonToken>> objectElement() => seq5(
    ref1(stringToken, true),
    ref0(whitespaceSeq),
    char(':'),
    ref0(whitespaceSeq),
    ref1(value, false),
  ).map5((keyTokens, ws1, colon, ws2, valueTokens) {
    List<JsonToken> tokens = [
      ...keyTokens,
      ws1,
      JsonToken(value: colon, type: JsonTokenType.colon),
      ws2,
    ];
    if (valueTokens is List<JsonToken>) {
      tokens.addAll(valueTokens);
    } else if (valueTokens is String) {
      tokens.add(JsonToken(value: valueTokens, type: JsonTokenType.valueString));
    } else if (valueTokens is num) {
      tokens.add(JsonToken(value: valueTokens.toString(), type: JsonTokenType.valueNumber));
    } else if (valueTokens is bool) {
      tokens.add(JsonToken(value: valueTokens.toString(), type: JsonTokenType.valueBool));
    } else if (valueTokens == null) {
      tokens.add(JsonToken(value: 'null', type: JsonTokenType.valueNull));
    }
    return tokens.where((token) => token.value.isNotEmpty).toList();
  });

  Parser<JsonToken> whitespaceSeq() => whitespace().star().map(
    (chars) => JsonToken(value: chars.join(), type: JsonTokenType.whitespace),
  );

  Parser<bool> trueToken() => string('true').map((_) => true);
  Parser<bool> falseToken() => string('false').map((_) => false);
  Parser<Object?> nullToken() => string('null').map((_) => null);

  Parser<List<JsonToken>> stringToken([bool isKey = false]) => seq3(
    char('"'),
    ref0(characterPrimitive).star(),
    char('"'),
  ).map3(
    (start, chars, end) => [
      JsonToken(value: start, type: isKey ? JsonTokenType.keyQuote : JsonTokenType.valueQuote),
      JsonToken(value: chars.join(), type: isKey ? JsonTokenType.key : JsonTokenType.valueString),
      JsonToken(value: end, type: isKey ? JsonTokenType.keyQuote : JsonTokenType.valueQuote),
    ],
  );
  Parser<String> characterPrimitive() =>
      [ref0(characterNormal), ref0(characterEscape), ref0(characterUnicode)].toChoiceParser();
  Parser<String> characterNormal() => pattern('^"\\');
  Parser<String> characterEscape() => seq2(
    char('\\'),
    anyOf(jsonEscapeChars.keys.join()),
  ).map2((_, char) => jsonEscapeChars[char]!);
  Parser<String> characterUnicode() => seq2(
    string('\\u'),
    pattern('0-9A-Fa-f').timesString(4, '4-digit hex number expected'),
  ).map2((_, value) => String.fromCharCode(int.parse(value, radix: 16)));

  Parser<num> numberToken() =>
      ref0(numberPrimitive).flatten('number expected').trim().map(num.parse);
  Parser<void> numberPrimitive() =>
      <Parser<void>>[
        char('-').optional(),
        [char('0'), digit().plus()].toChoiceParser(),
        [char('.'), digit().plus()].toSequenceParser().optional(),
        [anyOf('eE'), anyOf('-+').optional(), digit().plus()].toSequenceParser().optional(),
      ].toSequenceParser();
}

enum JsonTokenType {
  objectBracket,
  keyQuote,
  key,
  valueQuote,
  valueNumber,
  valueBool,
  valueString,
  valueNull,
  colon,
  comma,
  punctuation,
  whitespace,
}

class JsonToken {
  final String value;
  final JsonTokenType type;

  JsonToken({required this.value, required this.type});

  @override
  String toString() {
    String valueString = switch (type) {
      JsonTokenType.whitespace => _whitespaceToName(value),
      _ => value.toString(),
    };

    return "$type(\"$valueString\")";
  }

  static String _whitespaceToName(String value) {
    if (value.isEmpty) return value;
    return switch (value) {
      ' ' => 'space',
      '\n' => 'newline',
      '\r' => 'carriage return',
      '\t' => 'tab',
      '\f' => 'form feed',
      '\v' => 'vertical tab',
      _ => '\\u${value.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}',
    };
  }
}
