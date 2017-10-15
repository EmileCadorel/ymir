module test.test;
import std.typecons;
import core.memory;
import core.stdio;



void _Y4test4test7printlnFsZv (Tuple!(ulong, char*) i) {
    _Y4core5stdio5printFsZv (i);
    _Y4core5stdio5printFaZv (cast (char) (10));
}

void main () {
    ulong __0__ = 0;
    immutable(char)* __1__ = "salut".ptr;
    char* __2__ = (cast (char*) GC.malloc (5));

    while (*(__1__) != 0)  {
        __2__ [__0__] = *(__1__);
        ++(__1__);
        ++(__0__);
    }
    Tuple!(ulong, char*) a = tuple (cast (ulong) (5), __2__);

    a [1] [cast (int) (1)] = cast (char) (114);
    _Y4test4test7printlnFsZv (a);
}
