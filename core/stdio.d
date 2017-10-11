module core.stdio;



extern (C) void putchar (const char c);

extern (C) void printf (const char* c, ...);

void print (char c) {
    putchar (c);
}

void print (char[] s) {
    if (s is null) {
        putchar (cast (char) (110));
        putchar (cast (char) (117));
        putchar (cast (char) (108));
        putchar (cast (char) (108));
    } else {
        for (ulong __0__ = 0 ; __0__ < s.length ; ++__0__)  {
            char* it = &s [__0__];

            putchar (*it);
        }
    }
}

void print (long i) {
    printf ((cast (char[]) "%ld"[]).ptr, i);
}

void print (int i) {
    printf ((cast (char[]) "%d"[]).ptr, i);
}

void print (short i) {
    printf ((cast (char[]) "%hd"[]).ptr, i);
}

void print (byte i) {
    printf ((cast (char[]) "%hhx"[]).ptr, i);
}

void print (ulong i) {
    printf ((cast (char[]) "%lu"[]).ptr, i);
}

void print (void* i) {
    printf ((cast (char[]) "%lu"[]).ptr, i);
}

void print (uint i) {
    printf ((cast (char[]) "%u"[]).ptr, i);
}

void print (ushort i) {
    printf ((cast (char[]) "%hu"[]).ptr, i);
}

void print (ubyte i) {
    printf ((cast (char[]) "%hhx"[]).ptr, i);
}

void print (double a, long prec) {
    printf ((cast (char[]) "%.*lf"[]).ptr, prec, a);
}

void print (double f) {
    printf ((cast (char[]) "%lf"[]).ptr, f);
}

void print (bool b) {
    if (b) {
        print ((cast (char[]) "true"[]));
    } else {
        print ((cast (char[]) "false"[]));
    }
}

struct A {
int a; 
}

