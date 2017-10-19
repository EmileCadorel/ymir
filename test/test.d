module test.test;
import std.typecons;
import core.memory;
import core.stdio;



void _Y4test4test7printlnFiZv (int i) {
    _Y4core5stdio5printFiZv (i);
    _Y4core5stdio5printFaZv (cast (char) (10));
}

void _Y4test4test3fooFcAiZv (const (Tuple!(ulong, int*)) a) {
    _Y4test4test7printlnFiZv (a [1] [cast (int) (0)]);
}

void main () {
    int* __0__ = (cast (int*) GC.malloc (1 * 4));

    __0__ [0] = cast (int) (1);
    Tuple!(ulong, int*) a = tuple (1, __0__);

    _Y4test4test3fooFcAiZv (a);
}
