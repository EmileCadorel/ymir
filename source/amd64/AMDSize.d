module amd64.AMDSize;
import std.typecons, std.algorithm, std.traits;
import lint.LSize;

alias SizeTuple = Tuple!(string, "id", int, "size");

enum AMDSize : SizeTuple {
    BYTE = SizeTuple ("b", 1),
    WORD = SizeTuple ("w", 2),
    DWORD = SizeTuple ("l", 4),
    QWORD = SizeTuple ("q", 8),
    SPREC = SizeTuple ("sp", -4),
	DPREC = SizeTuple ("dp", -8),
	NONE = SizeTuple ("", 0)
}

AMDSize getSize (LSize size) {
    switch (size.value) {
    case LSize.BYTE.value : return AMDSize.BYTE;
    case LSize.SHORT.value : return AMDSize.WORD;
    case LSize.INT.value : return AMDSize.DWORD;
    case LSize.LONG.value : return AMDSize.QWORD;
    case LSize.FLOAT.value : return AMDSize.SPREC;
    case LSize.DOUBLE.value : return AMDSize.DPREC;
    case LSize.NONE.value : return AMDSize.NONE;
    default : assert (false, "he bin !!");
    }
}
