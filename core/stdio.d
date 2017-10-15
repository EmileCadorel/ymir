module core.stdio;
import std.typecons;
import core.memory;



extern (C) void putchar (const (char) c);

extern (C) void printf (const (char*) c, ...);

void _Y4core5stdio5printFaZv (char c) {
    putchar (c);
}

void _Y4core5stdio5printFsZv (Tuple!(ulong, char*) s) {
    if (cast (const (bool)) (s [1] is null)) {
        putchar (cast (char) (110));
        putchar (cast (char) (117));
        putchar (cast (char) (108));
        putchar (cast (char) (108));
    } else  {
        ulong __3__ = 0;
        Tuple!(ulong, char*) __4__ = s;
        for (; __3__ < __4__ [0] ; ++(__3__))  {
            char* it = __4__ [1] + (__3__ * 1);

            putchar (*(it));
        }
    }
}

void _Y4core5stdio5printFlZv (long i) {
    printf ("%ld".ptr, i);
}

void _Y4core5stdio5printFiZv (int i) {
    printf ("%d".ptr, i);
}

void _Y4core5stdio5printFsdZv (short i) {
    printf ("%hd".ptr, i);
}

void _Y4core5stdio5printFbdZv (byte i) {
    printf ("%hhx".ptr, i);
}

void _Y4core5stdio5printFulZv (ulong i) {
    printf ("%lu".ptr, i);
}

void _Y4core5stdio5printFPvZv (void* i) {
    printf ("%lu".ptr, i);
}

void _Y4core5stdio5printFuiZv (uint i) {
    printf ("%u".ptr, i);
}

void _Y4core5stdio5printFusZv (ushort i) {
    printf ("%hu".ptr, i);
}

void _Y4core5stdio5printFubZv (ubyte i) {
    printf ("%hhx".ptr, i);
}

void _Y4core5stdio5printFflZv (double a, long prec) {
    printf ("%.*lf".ptr, prec, a);
}

void _Y4core5stdio5printFfZv (double f) {
    printf ("%lf".ptr, f);
}

void _Y4core5stdio5printFbZv (bool b) {
    if (b) {
        ulong __5__ = 0;
        immutable(char)* __6__ = "true".ptr;
        char* __7__ = (cast (char*) GC.malloc (4));

        while (*(__6__) != 0)  {
            __7__ [__5__] = *(__6__);
            ++(__6__);
            ++(__5__);
        }
        _Y4core5stdio5printFsZv (tuple (cast (ulong) (4), __7__));
    } else  {
        ulong __8__ = 0;
        immutable(char)* __9__ = "false".ptr;
        char* __10__ = (cast (char*) GC.malloc (5));

        while (*(__9__) != 0)  {
            __10__ [__8__] = *(__9__);
            ++(__9__);
            ++(__8__);
        }
        _Y4core5stdio5printFsZv (tuple (cast (ulong) (5), __10__));
    }
}
