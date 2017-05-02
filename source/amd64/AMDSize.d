module amd64.AMDSize;
import std.typecons, std.algorithm, std.traits;
import lint.LSize, std.conv;

alias SizeTuple = Tuple!(string, "id", int, "size", int, "value");

enum AMDSize : SizeTuple {
    BYTE = SizeTuple ("b", 1, 1),
    UBYTE = SizeTuple ("b", 1, 2),
    WORD = SizeTuple ("w", 2, 3),
    UWORD = SizeTuple ("w", 2, 4),
    DWORD = SizeTuple ("l", 4, 5),
    UDWORD = SizeTuple ("l", 4, 6),
    QWORD = SizeTuple ("q", 8, 7),
    UQWORD = SizeTuple ("q", 8, 8),
    SPREC = SizeTuple ("ss", 4, 9),
    DPREC = SizeTuple ("sd", 8, 10),
    NONE = SizeTuple ("", 0, 0)
}

AMDSize getSize (LSize size) {
    switch (size.value) {
    case LSize.BYTE.value : return AMDSize.BYTE;
    case LSize.UBYTE.value : return AMDSize.UBYTE;
    case LSize.SHORT.value : return AMDSize.WORD;
    case LSize.USHORT.value : return AMDSize.UWORD;
    case LSize.INT.value : return AMDSize.DWORD;
    case LSize.UINT.value : return AMDSize.UDWORD;
    case LSize.LONG.value : return AMDSize.QWORD;
    case LSize.ULONG.value : return AMDSize.UQWORD;
    case LSize.FLOAT.value : return AMDSize.SPREC;
    case LSize.DOUBLE.value : return AMDSize.DPREC;
    case LSize.NONE.value : return AMDSize.NONE;
    default : assert (false, "he bin !!" ~ to!string (size));
    }
}

bool isSigned (AMDSize size) {
    switch (size.value) {
    case AMDSize.BYTE.value : return true;
    case AMDSize.UBYTE.value : return false;
    case AMDSize.WORD.value : return true;
    case AMDSize.UWORD.value : return false;
    case AMDSize.DWORD.value : return true;
    case AMDSize.UDWORD.value : return false;
    case AMDSize.QWORD.value : return true;
    case AMDSize.UQWORD.value : return false;
    case AMDSize.SPREC.value : return false;
    case AMDSize.DPREC.value : return false;
    case AMDSize.NONE.value : return false;
    default : assert (false, "he bin !!" ~ to!string (size));
    }
}

bool isUnsigned (AMDSize size) {
    switch (size.value) {
    case AMDSize.BYTE.value : return false;
    case AMDSize.UBYTE.value : return true;
    case AMDSize.WORD.value : return false;
    case AMDSize.UWORD.value : return true;
    case AMDSize.DWORD.value : return false;
    case AMDSize.UDWORD.value : return true;
    case AMDSize.QWORD.value : return false;
    case AMDSize.UQWORD.value : return true;
    case AMDSize.SPREC.value : return false;
    case AMDSize.DPREC.value : return false;
    case AMDSize.NONE.value : return false;
    default : assert (false, "he bin !!" ~ to!string (size));
    }
}

AMDSize signedOne(AMDSize size) {
    switch (size.value) {
    case AMDSize.BYTE.value : return AMDSize.BYTE;
    case AMDSize.UBYTE.value : return AMDSize.BYTE;
    case AMDSize.WORD.value : return AMDSize.WORD;
    case AMDSize.UWORD.value : return AMDSize.WORD;
    case AMDSize.DWORD.value : return AMDSize.DWORD;
    case AMDSize.UDWORD.value : return AMDSize.DWORD;
    case AMDSize.QWORD.value : return AMDSize.QWORD;
    case AMDSize.UQWORD.value : return AMDSize.QWORD;
    case AMDSize.SPREC.value : return AMDSize.SPREC;
    case AMDSize.DPREC.value : return AMDSize.DPREC;
    case AMDSize.NONE.value : return AMDSize.NONE;
    default : assert (false, "he bin !!" ~ to!string (size));
    }
}

bool isInt (AMDSize size) {
    switch (size.value) {
    case AMDSize.BYTE.value : return true;
    case AMDSize.UBYTE.value : return true;
    case AMDSize.WORD.value : return true;
    case AMDSize.UWORD.value : return true;
    case AMDSize.DWORD.value : return true;
    case AMDSize.UDWORD.value : return true;
    case AMDSize.QWORD.value : return true;
    case AMDSize.UQWORD.value : return true;
    default: return false;
    }
}


