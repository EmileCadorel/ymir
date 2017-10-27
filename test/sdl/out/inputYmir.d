module inputYmir;
import std.typecons;
import core.memory;
import signalYmir;


 Tuple!(ulong, ST5inputSignal33NtupleNintU32ubyteNN **) Keyboard;
 Tuple!(ulong, ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN **) Mouse;
 ST5inputSignal33NtupleNNN * quitEvent;
 ST5inputSignal33NtupleNintU32intNN * resizeEvent;



struct ST5inputSDL_KeyboardEvent {
	int type; 
	uint timestamp; 
	uint windowId; 
	ubyte state; 
	ubyte repeat; 
	ubyte padding2; 
	ubyte padding3; 
	int scancode; 
	int sym; 
	ushort mode; 
	uint unicode; 
}


struct ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN {
	Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*) sig; 
}


struct ST5inputSignal33NtupleNintU32intNN {
	Tuple!(ulong, void function(Tuple!(int, int))*) sig; 
}


struct ST5inputSDL_MouseButtonEvent {
	uint type; 
	uint timestamp; 
	uint windowId; 
	uint which; 
	ubyte button; 
	ubyte state; 
	ubyte clicks; 
	ubyte padding1; 
	int x; 
	int y; 
}


struct ST5inputSignal33NtupleNintU32ubyteNN {
	Tuple!(ulong, void function(Tuple!(int, ubyte))*) sig; 
}


struct ST5inputSignal33NtupleNNN {
	Tuple!(ulong, void function(Tuple!())*) sig; 
}


extern (C) bool SDL_PollEvent ( ubyte* a);

ST5inputSignal33NtupleNintU32ubyteNN ** _Y5input8keyboardF11ESDL_KeycodeZR26STSignal33NtupleNintU32ubyteNN ( int key) {
    return (&Keyboard [1] [cast (int) (key)]);
}

ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN ** _Y5input5mouseF10ESDL_ButtonZR38STSignal33NtupleNubyteU32intU32intU32ubyteNN ( int button) {
    return (&Mouse [1] [cast (int) (button)]);
}

ST5inputSignal33NtupleNNN ** _Y5input4quitFZR16STSignal33NtupleNNN () {
    return (&quitEvent);
}

ST5inputSignal33NtupleNintU32intNN ** _Y5input6resizeFZR24STSignal33NtupleNintU32intNN () {
    return (&resizeEvent);
}

void _Y5input6opCallF26STSignal33NtupleNintU32ubyteNNTiubZv ( ST5inputSignal33NtupleNintU32ubyteNN * sig,  Tuple!(int, ubyte) param) {
    { ulong __0__ = 0;
     Tuple!(ulong, void function(Tuple!(int, ubyte))*) __1__ = (sig).sig;
    for (; __0__ < __1__ [0] ; (++__0__))  {
         void function(Tuple!(int, ubyte))* it = __1__ [1] + __0__;

        (*it) (param);
    }}
}

void _Y5input6opCallF38STSignal33NtupleNubyteU32intU32intU32ubyteNNTubiiubZv ( ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN * sig,  Tuple!(ubyte, int, int, ubyte) param) {
    { ulong __0__ = 0;
     Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*) __1__ = (sig).sig;
    for (; __0__ < __1__ [0] ; (++__0__))  {
         void function(Tuple!(ubyte, int, int, ubyte))* it = __1__ [1] + __0__;

        (*it) (param);
    }}
}

void _Y5input6opCallF16STSignal33NtupleNNNTZv ( ST5inputSignal33NtupleNNN * sig,  Tuple!() param) {
    { ulong __0__ = 0;
     Tuple!(ulong, void function(Tuple!())*) __1__ = (sig).sig;
    for (; __0__ < __1__ [0] ; (++__0__))  {
         void function(Tuple!())* it = __1__ [1] + __0__;

        (*it) (param);
    }}
}

bool _Y5input4pollFZb () {
     Tuple!(ulong, ubyte*) event = tuple (cast (ulong) (56U), (cast (ubyte*) GC.calloc ((ubyte).sizeof * cast (ulong) (56U))));

    if (SDL_PollEvent (event [1])) {
         ST5inputSDL_KeyboardEvent * sdlEvent = cast (ST5inputSDL_KeyboardEvent *) (event [1]);

        if (cast (bool) ((sdlEvent).type == cast (int) (768))) {
            if (cast (bool) (Keyboard [1] [(sdlEvent).sym] !is null)) {
                _Y5input6opCallF26STSignal33NtupleNintU32ubyteNNTiubZv (Keyboard [1] [(sdlEvent).sym], Tuple!(int, ubyte) ((sdlEvent).sym, (sdlEvent).state));
            }
            return false;
        } else if (cast (bool) ((sdlEvent).type == cast (int) (769))) {
            if (cast (bool) (Keyboard [1] [(sdlEvent).sym] !is null)) {
                _Y5input6opCallF26STSignal33NtupleNintU32ubyteNNTiubZv (Keyboard [1] [(sdlEvent).sym], Tuple!(int, ubyte) ((sdlEvent).sym, (sdlEvent).state));
            }
            return false;
        } else if (cast (bool) ((sdlEvent).type == cast (int) (1025))) {
             ST5inputSDL_MouseButtonEvent * buttonEvent = cast (ST5inputSDL_MouseButtonEvent *) (event [1]);

            if (cast (bool) (Mouse [1] [(buttonEvent).button] !is null)) {
                _Y5input6opCallF38STSignal33NtupleNubyteU32intU32intU32ubyteNNTubiiubZv (Mouse [1] [(buttonEvent).button], Tuple!(ubyte, int, int, ubyte) ((buttonEvent).button, (buttonEvent).x, (buttonEvent).y, (buttonEvent).state));
            }
        } else if (cast (bool) ((sdlEvent).type == cast (int) (256))) {
            _Y5input6opCallF16STSignal33NtupleNNNTZv (quitEvent, Tuple!() ());
        }
    }
    return false;
}

void _Y5input4selfFZv () {
    Keyboard = tuple (cast (uint) (512U), (cast (ST5inputSignal33NtupleNintU32ubyteNN **) GC.calloc ((ST5inputSignal33NtupleNintU32ubyteNN *).sizeof * cast (uint) (512U))));
    Mouse = tuple (cast (uint) (6U), (cast (ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN **) GC.calloc ((ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN *).sizeof * cast (uint) (6U))));
    resizeEvent = new ST5inputSignal33NtupleNintU32intNN ();
    quitEvent = new ST5inputSignal33NtupleNNN ();
}
