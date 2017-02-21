module lint.LSize;
import std.typecons, std.algorithm, std.traits;

alias LSizeTuple = Tuple!(string, "value", int, "id");

enum LSize : LSizeTuple {
    BYTE = LSizeTuple ("byte", 1),
    UBYTE = LSizeTuple ("ubyte", 2),
    SHORT = LSizeTuple ("word", 3),
    USHORT = LSizeTuple ("uword", 4),
    INT = LSizeTuple ("int", 5),
    UINT = LSizeTuple ("uint", 6),
    LONG = LSizeTuple ("long", 7),
    ULONG = LSizeTuple ("ulong", 8),
    FLOAT = LSizeTuple ("float", 9),
    DOUBLE = LSizeTuple ("double", 10),
    NONE = LSizeTuple ("none", 11)
}
