module amd64.AMDSize;
import std.typecons, std.algorithm, std.traits;


alias SizeTuple = Tuple!(string, "id", int, "size");

enum AMDSize : SizeTuple {
    BYTE = SizeTuple ("b", 1),
    WORD = SizeTuple ("w", 2),
    DWORD = SizeTuple ("d", 4),
    QWORD = SizeTuple ("q", 8),
    SPREC = SizeTuple ("sp", -4),
	DPREC = SizeTuple ("dp", -8),
	NONE = SizeTuple ("", 0)
}

AMDSize getSize (int size) {
    auto elem = find !"a.size == b" ([EnumMembers!AMDSize], size);
    if (elem != []) return elem[0];
    return AMDSize.NONE;
}
