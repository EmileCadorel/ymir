module sdlYmir;
import std.typecons;
import core.memory;
import coreYmir.intYmir;
import coreYmir.stringYmir;
import coreYmir.stdioYmir;
import coreYmir.arrayYmir;
import stdYmir.stringYmir;
import sdlYmir;
import stdYmir.convYmir;





struct ST3sdlSDL_Window {
	void* content; 

	static ST3sdlSDL_Window* cstNew () {
		auto self = new ST3sdlSDL_Window ();
		self.cst ();
		return self;
	}

	static ST3sdlSDL_Window* cstNew (void* content) {
		auto self = new ST3sdlSDL_Window ();
		self.cst ();
		self.content = content;
		return self;
	}

	void cst () {
		alias self = this;
	}

}


struct ST3sdlGL_Context {
	void* val; 

	static ST3sdlGL_Context* cstNew () {
		auto self = new ST3sdlGL_Context ();
		self.cst ();
		return self;
	}

	static ST3sdlGL_Context* cstNew (void* val) {
		auto self = new ST3sdlGL_Context ();
		self.cst ();
		self.val = val;
		return self;
	}

	void cst () {
		alias self = this;
	}

}


struct ST3sdlWindow {
	ST3sdlSDL_Window * win; 
	ST3sdlGL_Context * ctx; 

	static ST3sdlWindow* cstNew () {
		auto self = new ST3sdlWindow ();
		self.cst ();
		return self;
	}

	static ST3sdlWindow* cstNew (ST3sdlSDL_Window * win, ST3sdlGL_Context * ctx) {
		auto self = new ST3sdlWindow ();
		self.cst ();
		self.win = win;
		self.ctx = ctx;
		return self;
	}

	void cst () {
		alias self = this;
	}

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
         Tuple!(ulong, char*) __0__ = Tuple!(ulong, char*) (15, cast (char*) (("Init sdl failed").ptr));

        assert (false, __0__ [1] [0 .. __0__ [0]]);
    }
    return (ST3sdlSDL_Window).cstNew (SDL_CreateWindow (_Y3std6string9toStringzFcsZs (name) [1], cast (int) (0), cast (int) (0), width, height, cast (int) (38)));
}

ST3sdlGL_Context * _Y3sdl13createContextF10STSDL_WindowZ10STGL_Context ( ST3sdlSDL_Window * win) {
    return (ST3sdlGL_Context).cstNew (SDL_GL_CreateContext ((win).content));
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
    return Tuple!(ulong, char*) (0, cast (char*) (("").ptr));
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU4U5NFZcs () {
    return Tuple!(ulong, char*) (1, cast (char*) (("c").ptr));
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU3U5NFZcs () {
    return Tuple!(ulong, char*) (2, cast (char*) (("c!").ptr));
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU2U5NFZcs () {
    return Tuple!(ulong, char*) (3, cast (char*) (("c!r").ptr));
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU1U5NFZcs () {
    return Tuple!(ulong, char*) (4, cast (char*) (("c!rt").ptr));
}

Tuple!(ulong, char*) _Y3sdl22sliceNGptr33charGU0U5NFZcs () {
    return Tuple!(ulong, char*) (5, cast (char*) (("c!rtp").ptr));
}

bool _Y3sdl11isTupleNPaNFZb () {
    return false;
}

Tuple!(ulong, char*) _Y3sdl14opBinaryNG43GNFAaAaZAa ( Tuple!(ulong, char*) a,  Tuple!(ulong, char*) b) {
     Tuple!(ulong, char*) c = tuple (cast (ulong) (a [0] + b [0]), (cast (char*) (new  char [cast (ulong) (a [0] + b [0])]).ptr));

    { uint __0__ = tuple (cast (uint) (0U), cast (uint) (a [0])) [0];
     Tuple!(uint, uint) __1__ = tuple (cast (uint) (0U), cast (uint) (a [0]));
    for (; (__1__ [0] < __1__ [1] ? __0__ < __1__ [1] : __0__ > __1__ [1]) ; (__1__ [0] < __1__ [1] ? (++(__0__)) : (--(__0__))))  {
         uint it = __0__;

        c [1] [it] = a [1] [it];
    }}
    { uint __2__ = tuple (cast (uint) (0U), cast (uint) (b [0])) [0];
     Tuple!(uint, uint) __3__ = tuple (cast (uint) (0U), cast (uint) (b [0]));
    for (; (__3__ [0] < __3__ [1] ? __2__ < __3__ [1] : __2__ > __3__ [1]) ; (__3__ [0] < __3__ [1] ? (++(__2__)) : (--(__2__))))  {
         uint it = __2__;

        c [1] [cast (ulong) (cast (ulong) (it) + a [0])] = b [1] [it];
    }}
    return c;
}

Tuple!(ulong, char*) _Y3sdl5toNsNFPaZs ( char* a) {
    if (cast (bool) (a is null)) {
        return Tuple!(ulong, char*) (0, cast (char*) (("").ptr));
    } else if (cast (bool) ((*(a)) == cast (ubyte) (0U))) {
        return Tuple!(ulong, char*) (0, cast (char*) (("").ptr));
    }
     char* __0__ = (cast (char*) (new  char [1]).ptr);

    __0__ [0] = (*(a));
     Tuple!(ulong, char*) ret = tuple (cast (ulong) (1), __0__);

    a = cast (char*) (a + cast (int) (1));
    while (cast (bool) ((*(a)) != cast (ubyte) (0U)))  {
         char* __1__ = (cast (char*) (new  char [1]).ptr);

        __1__ [0] = (*(a));
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
    return (ST3sdlWindow).cstNew (win, context);
}

void _Y3sdl5clearF6STWindowZv ( ST3sdlWindow * win) {
    glClear (cast (int) (16640));
}

void _Y3sdl10swapWindowF6STWindowZv ( ST3sdlWindow * window) {
    SDL_GL_SwapWindow (((window).win).content);
}

void _Y3sdl4selfFZv () {
}
