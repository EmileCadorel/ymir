module lint.LSize;
import std.typecons, std.algorithm, std.traits;
import ast.Constante;

struct LSizeTuple {
    string value;
    int id;
}

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

LSize fromDecimalConst (DecimalConst size) {
    final switch (size.id) {
    case DecimalConst.BYTE.id : return LSize.BYTE;
    case DecimalConst.UBYTE.id : return LSize.UBYTE;
    case DecimalConst.SHORT.id : return LSize.SHORT;
    case DecimalConst.USHORT.id : return LSize.USHORT;
    case DecimalConst.INT.id : return LSize.INT;
    case DecimalConst.UINT.id : return LSize.UINT;
    case DecimalConst.LONG.id : return LSize.LONG;
    case DecimalConst.ULONG.id : return LSize.ULONG;
    }
}
