module sdlYmir;
import std.typecons;
import core.memory;
import stdYmir.stringYmir;
import coreYmir.intYmir;
import stdYmir.convYmir;





struct ST3sdlSDL_Window {
	void* content; 
}


struct ST3sdlGL_Context {
	void* val; 
}


struct ST3sdlWindow {
	ST3sdlSDL_Window * win; 
	ST3sdlGL_Context * ctx; 
}


extern (C) void SDL_Quit ();

extern (C) int SDL_Init ( int _);

extern (C) void* SDL_CreateWindow ( char* name,  int posx,  int posy,  int width,  int height,  int options);

extern (C) void* SDL_GL_CreateContext ( void* win);

extern (C) int glewInit ();

extern (C) char* glewGetErrorString ( int _);

extern (C) void glEnable ( int _);

extern (C) void glClearColor ( double _,  double _,  double _,  double _);

extern (C) void glClear ( int _);

extern (C) void SDL_GL_SwapWindow ( void* win);

ST3sdlSDL_Window * _Y3sdl12createWindowFcsiiZ10STSDL_Window ( Tuple!(ulong, char*) name,  int width,  int height) {
    if (cast (bool) (SDL_Init (cast (int) (32)) < cast (int) (0))) {
        SDL_Quit ();
         Tuple!(ulong, char*) __0__ = _Y3sdl100CstStringFZv (15, ("Init sdl failed").ptr);

        assert (false, __0__ [1] [0 .. __0__ [0]]);
    }
    return new ST3sdlSDL_Window (SDL_CreateWindow (_Y3std6string9toStringzFcsZs (name) [1], cast (int) (0), cast (int) (0), width, height, cast (int) (38)));
}

ST3sdlGL_Context * _Y3sdl13createContextF10STSDL_WindowZ10STGL_Context ( ST3sdlSDL_Window * win) {
    return new ST3sdlGL_Context (SDL_GL_CreateContext ((win).content));
}

bool _Y3sdl12isDecimalNsNFZb () {
    return false;
}

bool _Y3sdl14isUnsignedNPaNFZb () {
    return false;
}

bool _Y3sdl13isDecimalNPaNFZb () {
    return false;
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU5U5NFZcs () {
    return _Y3sdl100CstStringFZv (0, ("").ptr);
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU4U5NFZcs () {
    return _Y3sdl100CstStringFZv (1, ("c").ptr);
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU3U5NFZcs () {
    return _Y3sdl100CstStringFZv (2, ("c!").ptr);
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU2U5NFZcs () {
    return _Y3sdl100CstStringFZv (3, ("c!r").ptr);
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU1U5NFZcs () {
    return _Y3sdl100CstStringFZv (4, ("c!rt").ptr);
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU0U5NFZcs () {
    return _Y3sdl100CstStringFZv (5, ("c!rtp").ptr);
}

bool _Y3sdl11isTupleNPaNFZb () {
    return false;
}

Tuple!(ulong, char*) _Y3sdl14opBinaryNG43GNFAaAaZAa ( Tuple!(ulong, char*) a,  Tuple!(ulong, char*) b) {
     Tuple!(ulong, char*) c = tuple (cast (ulong) (a [0] + b [0]), (cast (char*) GC.calloc ((char).sizeof * cast (ulong) (a [0] + b [0]))));

    { uint __0__ = tuple (cast (uint) (0U), cast (uint) (a [0])) [0];
     Tuple!(uint, uint) __1__ = tuple (cast (uint) (0U), cast (uint) (a [0]));
    for (; (__1__ [0] < __1__ [1] ? __0__ < __1__ [1] : __0__ > __1__ [1]) ; (__1__ [0] < __1__ [1] ? (++__0__) : (--__0__)))  {
         uint it = __0__;

        c [1] [it] = a [1] [it];
    }}
    { uint __2__ = tuple (cast (uint) (0U), cast (uint) (b [0])) [0];
     Tuple!(uint, uint) __3__ = tuple (cast (uint) (0U), cast (uint) (b [0]));
    for (; (__3__ [0] < __3__ [1] ? __2__ < __3__ [1] : __2__ > __3__ [1]) ; (__3__ [0] < __3__ [1] ? (++__2__) : (--__2__)))  {
         uint it = __2__;

        c [1] [cast (ulong) (cast (ulong) (it) + a [0])] = b [1] [it];
    }}
    return c;
}

Tuple!(ulong, char*) _Y3sdl5toNsNFPaZs ( char* a) {
    if (cast (bool) (a is null)) {
        return _Y3sdl100CstStringFZv (0, ("").ptr);
    } else if (cast (bool) ((*a) == cast (ubyte) (0U))) {
        return _Y3sdl100CstStringFZv (0, ("").ptr);
    }
     char* __0__ = (cast (char*) GC.calloc (1 * 1U));

    __0__ [0] = (*a);
     Tuple!(ulong, char*) ret = tuple (cast (ulong) (1), __0__);

    a = cast (char*) (a + cast (int) (1));
    while (cast (bool) ((*a) != cast (ubyte) (0U)))  {
         char* __1__ = (cast (char*) GC.calloc (1 * 1U));

        __1__ [0] = (*a);
        ret = _Y3sdl14opBinaryNG43GNFAaAaZAa (ret, tuple (cast (ulong) (1), __1__));
        a = cast (char*) (a + cast (int) (1));
    }
    return cast (Tuple!(ulong, char*)) (ret);
}

ST3sdlWindow * _Y3sdl7initSDLFcsiiZ6STWindow ( Tuple!(ulong, char*) name,  int width,  int height) {
     ST3sdlSDL_Window * win = _Y3sdl12createWindowFcsiiZ10STSDL_Window (name, width, height);

     ST3sdlGL_Context * context = _Y3sdl13createContextF10STSDL_WindowZ10STGL_Context (win);

     int e = glewInit ();

    if (cast (bool) (e != cast (int) (0))) {
         Tuple!(ulong, char*) __0__ = _Y3sdl5toNsNFPaZs (glewGetErrorString (e));

        assert (false, __0__ [1] [0 .. __0__ [0]]);
    }
    glEnable (cast (int) (3553));
    glEnable (cast (int) (2884));
    glEnable (cast (int) (2929));
    glClearColor (0.0, 0.0, 0.0, 1.0);
    return new ST3sdlWindow (win, context);
}

void _Y3sdl5clearF6STWindowZv ( ST3sdlWindow * win) {
    glClear (cast (int) (16640));
}

void _Y3sdl10swapWindowF6STWindowZv ( ST3sdlWindow * window) {
    SDL_GL_SwapWindow (((window).win).content);
}

void _Y3sdl4selfFZv () {
}

Tuple!(ulong, char*) _Y3sdl100CstStringFZv ( ulong len,  const (char)* ptr) {
     ulong __1__ = 0;
     char* __2__ = (cast (char*) GC.calloc (len));

    while ((*ptr) != 0)  {
        __2__ [__1__] = (*ptr);
        (++ptr);
        (++__1__);
    }
    return tuple (cast (ulong) (__1__), __2__);
}
