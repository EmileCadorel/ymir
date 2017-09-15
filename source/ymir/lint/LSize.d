module ymir.lint.LSize;

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
    SHORT = LSizeTuple ("short", 3),
    USHORT = LSizeTuple ("ushort", 4),
    INT = LSizeTuple ("int", 5),
    UINT = LSizeTuple ("uint", 6),
    LONG = LSizeTuple ("long", 7),
    ULONG = LSizeTuple ("ulong", 8),
    FLOAT = LSizeTuple ("float", 9),
    DOUBLE = LSizeTuple ("double", 10),
    NONE = LSizeTuple ("none", 11)
}
