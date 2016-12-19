module lint.LSize;
import std.typecons, std.algorithm, std.traits;

alias LSizeTuple = Tuple!(string, "value", int, "id");

enum LSize : LSizeTuple {
    BYTE = LSizeTuple ("byte", 1),
    SHORT = LSizeTuple ("word", 2),
    INT = LSizeTuple ("int", 3),
    LONG = LSizeTuple ("long", 4),
    FLOAT = LSizeTuple ("float", 5),
    DOUBLE = LSizeTuple ("double", 6),
    NONE = LSizeTuple ("none", 7)
}
