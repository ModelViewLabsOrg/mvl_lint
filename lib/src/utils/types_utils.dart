import 'package:analyzer/dart/element/type.dart';

bool isIterable(DartType? type) =>
    _checkSelfOrSupertypes(type, (t) => t?.isDartCoreIterable ?? false);

bool isIterableOrSubclass(DartType? type) =>
    _checkSelfOrSupertypes(type, (t) => t?.isDartCoreIterable ?? false);

bool isListOrSubclass(DartType? type) =>
    _checkSelfOrSupertypes(type, (t) => t?.isDartCoreList ?? false);

bool _checkSelfOrSupertypes(
  DartType? type,
  bool Function(DartType?) predicate,
) => predicate(type) || (type is InterfaceType && type.allSupertypes.any(predicate));

bool hasIgnoredType(DartType? type, Set<String> ignoredTypes) {
  if (type == null || ignoredTypes.isEmpty) {
    return false;
  }

  final typeNames = <String>{
    type.getDisplayString(),
    ...type is InterfaceType
        ? type.allSupertypes.map((t) => t.getDisplayString())
        : const <String>[],
  };

  for (final ignored in ignoredTypes) {
    if (typeNames.any(
      (name) => name == ignored || name.startsWith('$ignored<'),
    )) {
      return true;
    }
  }

  return false;
}
