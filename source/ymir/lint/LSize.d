module ymir.lint.LSize;
import ymir.ast._;

import std.typecons, std.algorithm, std.traits;


struct LSizeTuple {
    string value;
    int id;


    string simple () {
	if (this.id <= 8) {
	    if (this.id % 2 == 1) return "" ~ this.value [0];
	    else return this.value [0 .. 2];
	} else return this.value;
    }

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
