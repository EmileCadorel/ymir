module target.TSize;
import std.typecons, std.algorithm, std.traits;
import std.container;

alias SizeTuple = Tuple!(string, "id", int, "size");

enum TSize : SizeTuple {
    BYTE = SizeTuple ("b", 1),
    WORD = SizeTuple ("w", 2),
    DWORD = SizeTuple ("d", 4),
    QWORD = SizeTuple ("q", 8),
    SPREC = SizeTuple ("sp", -4),
	DPREC = SizeTuple ("dp", -8),
	NONE = SizeTuple ("", 0)
}

TSize getSize (int size) {
    auto elem = find !"a.size == b" ([EnumMembers!TSize], size);
    if (elem != []) return elem[0];
    return TSize.NONE;
}
