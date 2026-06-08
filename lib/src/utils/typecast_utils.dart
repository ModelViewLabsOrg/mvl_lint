import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

/// Represents a type check or cast between [source] and [target].
class TypeCast {
  TypeCast({
    required this.source,
    required this.target,
    this.isReversed = false,
  });

  final DartType source;
  final DartType target;
  final bool isReversed;

  bool get isUnnecessaryTypeCheck {
    if (_isNullableCompatibility) {
      return false;
    }

    if (source.element == target.element) {
      return _areGenericsWithSameTypeArgs;
    }

    if (source case final InterfaceType interfaceType) {
      return interfaceType.allSupertypes.any(
        (e) => e.element == target.element,
      );
    }

    return false;
  }

  bool get _isNullableCompatibility {
    final isObjectTypeNullable = source.nullabilitySuffix != NullabilitySuffix.none;
    final isCastedTypeNullable = target.nullabilitySuffix != NullabilitySuffix.none;

    return isObjectTypeNullable && !isCastedTypeNullable;
  }

  bool get _areGenericsWithSameTypeArgs {
    if (source is DynamicType || target is DynamicType) {
      return false;
    }

    if (this case TypeCast(
      source: final objectType,
      target: final castedType,
    ) when objectType is ParameterizedType && castedType is ParameterizedType) {
      if (objectType.typeArguments.length != castedType.typeArguments.length) {
        return false;
      }

      return IterableZip([objectType.typeArguments, castedType.typeArguments])
          .map((e) => TypeCast(source: e[0], target: e[1]))
          .every((cast) => cast.isUnnecessaryTypeCheck);
    }

    return false;
  }
}
