module appYmir;
import std.typecons;
import core.memory;
import coreYmir.intYmir;
import coreYmir.stringYmir;
import coreYmir.stdioYmir;
import coreYmir.arrayYmir;
import stdYmir.stringYmir;
import sdlYmir;
import stdYmir.convYmir;
import stdYmir.arrayYmir;
import inputYmir;
import stdYmir.mapYmir;
import signalYmir;
import stdYmir.traitsYmir;
import stdYmir.mathYmir;
import stdYmir.algorithmYmir.comparaisonYmir;
import stdYmir.algorithmYmir.searchingYmir;
import stdYmir.stdioYmir._Ymir;
import stdYmir.stdioYmir.printYmir;
import stdYmir.stdioYmir.fileYmir;
import appYmir;


 bool END;



struct ST3appMapEntry33NintU32ubyteN {
	int key; 
	ubyte value; 
	ST3appMapEntry33NintU32ubyteN * left; 
	ST3appMapEntry33NintU32ubyteN * right; 

	static ST3appMapEntry33NintU32ubyteN* cstNew () {
		auto self = new ST3appMapEntry33NintU32ubyteN ();
		self.cst ();
		return self;
	}

	static ST3appMapEntry33NintU32ubyteN* cstNew (int key, ubyte value, ST3appMapEntry33NintU32ubyteN * left, ST3appMapEntry33NintU32ubyteN * right) {
		auto self = new ST3appMapEntry33NintU32ubyteN ();
		self.cst ();
		self.key = key;
		self.value = value;
		self.left = left;
		self.right = right;
		return self;
	}

	void cst () {
		alias self = this;
	}

}


void _Y3app4QuitFTZv ( Tuple!() a) {
    END = true;
}

bool _Y3app12isDecimalNsNFZb () {
    return false;
}

bool _Y3app16isUnsignedNTiubNFZb () {
    return false;
}

bool _Y3app15isDecimalNTiubNFZb () {
    return false;
}

Tuple!(ulong, char*) _Y3app31sliceNGtupleNintU32ubyteNGU5U5NFZcs () {
    return Tuple!(ulong, char*) (0, cast (char*) (("").ptr));
}

Tuple!(ulong, char*) _Y3app31sliceNGtupleNintU32ubyteNGU4U5NFZcs () {
    return Tuple!(ulong, char*) (1, cast (char*) (("e").ptr));
}

Tuple!(ulong, char*) _Y3app31sliceNGtupleNintU32ubyteNGU3U5NFZcs () {
    return Tuple!(ulong, char*) (2, cast (char*) (("el").ptr));
}

Tuple!(ulong, char*) _Y3app31sliceNGtupleNintU32ubyteNGU2U5NFZcs () {
    return Tuple!(ulong, char*) (3, cast (char*) (("elp").ptr));
}

Tuple!(ulong, char*) _Y3app31sliceNGtupleNintU32ubyteNGU1U5NFZcs () {
    return Tuple!(ulong, char*) (4, cast (char*) (("elpu").ptr));
}

Tuple!(ulong, char*) _Y3app31sliceNGtupleNintU32ubyteNGU0U5NFZcs () {
    return Tuple!(ulong, char*) (5, cast (char*) (("elput").ptr));
}

bool _Y3app13isTupleNTiubNFZb () {
    return true;
}

Tuple!(ulong, char*) _Y3app18sliceNGubyteGU5U5NFZcs () {
    return Tuple!(ulong, char*) (0, cast (char*) (("").ptr));
}

Tuple!(ulong, char*) _Y3app18sliceNGubyteGU4U5NFZcs () {
    return Tuple!(ulong, char*) (1, cast (char*) (("e").ptr));
}

Tuple!(ulong, char*) _Y3app18sliceNGubyteGU3U5NFZcs () {
    return Tuple!(ulong, char*) (2, cast (char*) (("et").ptr));
}

Tuple!(ulong, char*) _Y3app18sliceNGubyteGU2U5NFZcs () {
    return Tuple!(ulong, char*) (3, cast (char*) (("ety").ptr));
}

Tuple!(ulong, char*) _Y3app18sliceNGubyteGU1U5NFZcs () {
    return Tuple!(ulong, char*) (4, cast (char*) (("etyb").ptr));
}

Tuple!(ulong, char*) _Y3app18sliceNGubyteGU0U5NFZcs () {
    return Tuple!(ulong, char*) (5, cast (char*) (("etybu").ptr));
}

bool _Y3app11isTupleNubNFZb () {
    return false;
}

bool _Y3app11isArrayNubNFZb () {
    return false;
}

bool _Y3app15isPrimitiveNubNFZb () {
    return true;
}

bool _Y3app14isUnsignedNubNFZb () {
    return true;
}

bool _Y3app13isDecimalNubNFZb () {
    return true;
}

byte _Y3app8toSignedFubZbd ( ubyte elem) {
     {
        return cast (byte) (cast (byte) (elem));
    }
}

bool _Y3app14isUnsignedNbdNFZb () {
    return false;
}

bool _Y3app13isDecimalNbdNFZb () {
    return true;
}

Tuple!(ulong, char*) _Y3app17sliceNGbyteGU4U5NFZcs () {
    return Tuple!(ulong, char*) (0, cast (char*) (("").ptr));
}

Tuple!(ulong, char*) _Y3app17sliceNGbyteGU3U5NFZcs () {
    return Tuple!(ulong, char*) (1, cast (char*) (("e").ptr));
}

Tuple!(ulong, char*) _Y3app17sliceNGbyteGU2U5NFZcs () {
    return Tuple!(ulong, char*) (2, cast (char*) (("et").ptr));
}

Tuple!(ulong, char*) _Y3app17sliceNGbyteGU1U5NFZcs () {
    return Tuple!(ulong, char*) (3, cast (char*) (("ety").ptr));
}

Tuple!(ulong, char*) _Y3app17sliceNGbyteGU0U5NFZcs () {
    return Tuple!(ulong, char*) (4, cast (char*) (("etyb").ptr));
}

bool _Y3app11isTupleNbdNFZb () {
    return false;
}

Tuple!(ulong, char*) _Y3app5toNsNFbdZs ( byte elem) {
     int aux = cast (int) (cast (int) (elem));

     int right = cast (int) (aux % cast (int) (16));

     int left = cast (int) (aux / cast (int) (16));

     Tuple!(ulong, char*) ret = tuple (cast (ulong) (2U), (cast (char*) (new  char [cast (ulong) (2U)]).ptr));

    if (cast (bool) (right <= cast (int) (9))) {
        ret [1] [cast (int) (1)] = cast (char) (cast (char) (cast (char) (right)) + cast (char) (48));
    } else  {
        ret [1] [cast (int) (1)] = cast (char) (cast (char) (cast (char) (cast (int) (right - cast (int) (10)))) + cast (char) (97));
    }
    if (cast (bool) (left <= cast (int) (9))) {
        ret [1] [cast (int) (0)] = cast (char) (cast (char) (cast (char) (left)) + cast (char) (48));
    } else  {
        ret [1] [cast (int) (0)] = cast (char) (cast (char) (cast (char) (cast (int) (left - cast (int) (10)))) + cast (char) (97));
    }
    return cast (Tuple!(ulong, char*)) (ret);
}

Tuple!(ulong, char*) _Y3app5toNsNFubZs ( ubyte elem) {
    return _Y3app5toNsNFbdZs (_Y3app8toSignedFubZbd (elem));
}

Tuple!(ulong, char*) _Y3app12addTupleComaFubZs ( ubyte left) {
    return _Y3app5toNsNFubZs (left);
}

bool _Y3app13isUnsignedNiNFZb () {
    return false;
}

bool _Y3app12isDecimalNiNFZb () {
    return true;
}

Tuple!(ulong, char*) _Y3app16sliceNGintGU3U5NFZcs () {
    return Tuple!(ulong, char*) (0, cast (char*) (("").ptr));
}

Tuple!(ulong, char*) _Y3app16sliceNGintGU2U5NFZcs () {
    return Tuple!(ulong, char*) (1, cast (char*) (("t").ptr));
}

Tuple!(ulong, char*) _Y3app16sliceNGintGU1U5NFZcs () {
    return Tuple!(ulong, char*) (2, cast (char*) (("tn").ptr));
}

Tuple!(ulong, char*) _Y3app16sliceNGintGU0U5NFZcs () {
    return Tuple!(ulong, char*) (3, cast (char*) (("tni").ptr));
}

bool _Y3app10isTupleNiNFZb () {
    return false;
}

int _Y3app5toNiNFbdZi ( byte elem) {
     {
        return cast (int) (cast (int) (elem));
    }
}

ulong* _Y3app15opUnaryNG4343GNFRulZRul ( ulong* a) {
     {
        (*(a)) = cast (ulong) ((*(a)) + cast (ulong) (1U));
    }
    return a;
}

int _Y3app5toNiNFubZi ( ubyte elem) {
     {
        return cast (int) (cast (int) (elem));
    }
}

Tuple!(ulong, char*) _Y3app5toNsNFiZs ( int elem) {
    if (cast (bool) (elem < cast (int) (0))) {
        return _Y4core6string14opBinaryNG43GNFcscsZs (Tuple!(ulong, char*) (1, cast (char*) (("-").ptr)), _Y3app5toNsNFiZs ((-(elem))));
    } else if (cast (bool) (elem == cast (int) (0))) {
        return Tuple!(ulong, char*) (1, cast (char*) (("0").ptr));
    }
     int nb = elem;
     ulong size = cast (ulong) (0U);

    while (cast (bool) (nb > cast (int) (0)))  {
        nb = (nb / _Y3app5toNiNFbdZi (cast (byte) (10)));
        _Y3app15opUnaryNG4343GNFRulZRul ((&(size)));
    }
     Tuple!(ulong, char*) res = tuple (size, (cast (char*) (new  char [size]).ptr));

    { ulong __0__ = tuple (cast (ulong) (0U), size) [0];
     Tuple!(ulong, ulong) __1__ = tuple (cast (ulong) (0U), size);
    for (; (__1__ [0] < __1__ [1] ? __0__ < __1__ [1] : __0__ > __1__ [1]) ; (__1__ [0] < __1__ [1] ? (++(__0__)) : (--(__0__))))  {
         ulong it = __0__;

        res [1] [cast (ulong) (cast (ulong) (size - it) - cast (ulong) (1U))] = cast (char) (cast (char) (cast (char) (cast (int) (elem % _Y3app5toNiNFubZi (cast (ubyte) (10U))))) + cast (char) (48));
        elem = (elem / _Y3app5toNiNFubZi (cast (ubyte) (10U)));
    }}
    return cast (Tuple!(ulong, char*)) (res);
}

Tuple!(ulong, char*) _Y3app12addTupleComaFiubZs ( int left,  ubyte elem) {
     {
        return _Y4core6string14opBinaryNG43GNFcscsZs (_Y4core6string14opBinaryNG43GNFcscsZs (_Y3app5toNsNFiZs (left), Tuple!(ulong, char*) (2, cast (char*) ((", ").ptr))), _Y3app12addTupleComaFubZs (elem));
    }
}

Tuple!(ulong, char*) _Y3app5toNsNFTiubZs ( Tuple!(int, ubyte) elem) {
     Tuple!(int, ubyte) __0__ = elem;

    return _Y4core6string14opBinaryNG43GNFcsaZcs (_Y4core6string14opBinaryNG43GNFcscsZs (Tuple!(ulong, char*) (6, cast (char*) (("tuple(").ptr)), _Y3app12addTupleComaFiubZs (__0__ [0], __0__ [1])), cast (char) (41));
}

void _Y3app5printFTiubZv ( Tuple!(int, ubyte) a) {
    _Y4core5stdio5printFcsZv (Tuple!(ulong, char*) (1, cast (char*) (("(").ptr)));
    _Y4core5stdio5printFcsZv (_Y3app5toNsNFTiubZs (a));
    _Y4core5stdio5printFcsZv (Tuple!(ulong, char*) (1, cast (char*) ((")").ptr)));
}

void _Y3app7printlnFTiubZv ( Tuple!(int, ubyte) i) {
    _Y3app5printFTiubZv (i);
    _Y4core5stdio5printFaZv (cast (char) (10));
}

void _Y3app3endFTiubZv ( Tuple!(int, ubyte) a) {
    _Y3app7printlnFTiubZv (a);
    END = true;
}

void _Y3app5printFalZv ( char i,  long nexts) {
    _Y4core5stdio5printFaZv (i);
    _Y4core5stdio5printFlZv (nexts);
}

void _Y3app7printlnVFlTalZv ( long i,  Tuple!(char, long) next) {
    _Y4core5stdio5printFlZv (i);
     Tuple!(char, long) __0__ = next;

    _Y3app5printFalZv (__0__ [0], __0__ [1]);
    _Y4core5stdio5printFaZv (cast (char) (10));
}

void _Y3app4testFTubiiubZv ( Tuple!(ubyte, int, int, ubyte) a) {
     long x = cast (long) (cast (long) (a [1]));

     long y = cast (long) (cast (long) (a [2]));

    _Y3app7printlnVFlTalZv (x, Tuple!(char, long) (cast (char) (32), y));
}

void _Y3app7printlnFbZv ( bool i) {
    _Y4core5stdio5printFbZv (i);
    _Y4core5stdio5printFaZv (cast (char) (10));
}

Tuple!(ulong, void function(Tuple!(int, ubyte))*) _Y3app14opBinaryNG43GNFAf_TiubAf_TiubZAf_Tiub ( Tuple!(ulong, void function(Tuple!(int, ubyte))*) a,  Tuple!(ulong, void function(Tuple!(int, ubyte))*) b) {
     Tuple!(ulong, void function(Tuple!(int, ubyte))*) c = tuple (cast (ulong) (a [0] + b [0]), (cast (void function(Tuple!(int, ubyte))*) (new  void function(Tuple!(int, ubyte)) [cast (ulong) (a [0] + b [0])]).ptr));

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

Tuple!(ulong, void function(Tuple!(int, ubyte))*)* _Y3app16opAssignNG4361GNFRAf_TiubAf_TiubZRAf_Tiub ( Tuple!(ulong, void function(Tuple!(int, ubyte))*)* a,  Tuple!(ulong, void function(Tuple!(int, ubyte))*) b) {
    (*(a)) = _Y3app14opBinaryNG43GNFAf_TiubAf_TiubZAf_Tiub ((*(a)), b);
    return a;
}

void _Y3app7printlnFulZv ( ulong i) {
    _Y4core5stdio5printFulZv (i);
    _Y4core5stdio5printFaZv (cast (char) (10));
}

void _Y3app7connectFR26STSignal33NtupleNintU32ubyteNNf_TiubZv ( ST5inputSignal33NtupleNintU32ubyteNN ** sig,  void function(Tuple!(int, ubyte)) fun) {
    if (cast (bool) ((*(sig)) is null)) {
        (*(sig)) = (ST5inputSignal33NtupleNintU32ubyteNN).cstNew ();
    }
    _Y3app7printlnFbZv (cast (bool) (((*(sig))).sig [1] is null));
    if (cast (bool) (((*(sig))).sig [1] is null)) {
         void function(Tuple!(int, ubyte))* __0__ = (cast (void function(Tuple!(int, ubyte))*) (new  void function(Tuple!(int, ubyte)) [1]).ptr);

        __0__ [0] = fun;
        ((*(sig))).sig = tuple (cast (ulong) (1), __0__);
    } else  {
         void function(Tuple!(int, ubyte))* __1__ = (cast (void function(Tuple!(int, ubyte))*) (new  void function(Tuple!(int, ubyte)) [1]).ptr);

        __1__ [0] = fun;
        _Y3app16opAssignNG4361GNFRAf_TiubAf_TiubZRAf_Tiub ((&(((*(sig))).sig)), tuple (cast (ulong) (1), __1__));
    }
    _Y3app7printlnFulZv (((*(sig))).sig [0]);
}

Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*) _Y3app14opBinaryNG43GNFAf_TubiiubAf_TubiiubZAf_Tubiiub ( Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*) a,  Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*) b) {
     Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*) c = tuple (cast (ulong) (a [0] + b [0]), (cast (void function(Tuple!(ubyte, int, int, ubyte))*) (new  void function(Tuple!(ubyte, int, int, ubyte)) [cast (ulong) (a [0] + b [0])]).ptr));

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

Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*)* _Y3app16opAssignNG4361GNFRAf_TubiiubAf_TubiiubZRAf_Tubiiub ( Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*)* a,  Tuple!(ulong, void function(Tuple!(ubyte, int, int, ubyte))*) b) {
    (*(a)) = _Y3app14opBinaryNG43GNFAf_TubiiubAf_TubiiubZAf_Tubiiub ((*(a)), b);
    return a;
}

void _Y3app7connectFR38STSignal33NtupleNubyteU32intU32intU32ubyteNNf_TubiiubZv ( ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN ** sig,  void function(Tuple!(ubyte, int, int, ubyte)) fun) {
    if (cast (bool) ((*(sig)) is null)) {
        (*(sig)) = (ST5inputSignal33NtupleNubyteU32intU32intU32ubyteNN).cstNew ();
    }
    _Y3app7printlnFbZv (cast (bool) (((*(sig))).sig [1] is null));
    if (cast (bool) (((*(sig))).sig [1] is null)) {
         void function(Tuple!(ubyte, int, int, ubyte))* __0__ = (cast (void function(Tuple!(ubyte, int, int, ubyte))*) (new  void function(Tuple!(ubyte, int, int, ubyte)) [1]).ptr);

        __0__ [0] = fun;
        ((*(sig))).sig = tuple (cast (ulong) (1), __0__);
    } else  {
         void function(Tuple!(ubyte, int, int, ubyte))* __1__ = (cast (void function(Tuple!(ubyte, int, int, ubyte))*) (new  void function(Tuple!(ubyte, int, int, ubyte)) [1]).ptr);

        __1__ [0] = fun;
        _Y3app16opAssignNG4361GNFRAf_TubiiubAf_TubiiubZRAf_Tubiiub ((&(((*(sig))).sig)), tuple (cast (ulong) (1), __1__));
    }
    _Y3app7printlnFulZv (((*(sig))).sig [0]);
}

Tuple!(ulong, void function(Tuple!())*) _Y3app14opBinaryNG43GNFAf_TAf_TZAf_T ( Tuple!(ulong, void function(Tuple!())*) a,  Tuple!(ulong, void function(Tuple!())*) b) {
     Tuple!(ulong, void function(Tuple!())*) c = tuple (cast (ulong) (a [0] + b [0]), (cast (void function(Tuple!())*) (new  void function(Tuple!()) [cast (ulong) (a [0] + b [0])]).ptr));

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

Tuple!(ulong, void function(Tuple!())*)* _Y3app16opAssignNG4361GNFRAf_TAf_TZRAf_T ( Tuple!(ulong, void function(Tuple!())*)* a,  Tuple!(ulong, void function(Tuple!())*) b) {
    (*(a)) = _Y3app14opBinaryNG43GNFAf_TAf_TZAf_T ((*(a)), b);
    return a;
}

void _Y3app7connectFR16STSignal33NtupleNNNf_TZv ( ST5inputSignal33NtupleNNN ** sig,  void function(Tuple!()) fun) {
    if (cast (bool) ((*(sig)) is null)) {
        (*(sig)) = (ST5inputSignal33NtupleNNN).cstNew ();
    }
    _Y3app7printlnFbZv (cast (bool) (((*(sig))).sig [1] is null));
    if (cast (bool) (((*(sig))).sig [1] is null)) {
         void function(Tuple!())* __0__ = (cast (void function(Tuple!())*) (new  void function(Tuple!()) [1]).ptr);

        __0__ [0] = fun;
        ((*(sig))).sig = tuple (cast (ulong) (1), __0__);
    } else  {
         void function(Tuple!())* __1__ = (cast (void function(Tuple!())*) (new  void function(Tuple!()) [1]).ptr);

        __1__ [0] = fun;
        _Y3app16opAssignNG4361GNFRAf_TAf_TZRAf_T ((&(((*(sig))).sig)), tuple (cast (ulong) (1), __1__));
    }
    _Y3app7printlnFulZv (((*(sig))).sig [0]);
}

void main () {
    _Y4core3int4selfFZv ();
    _Y4core6string4selfFZv ();
    _Y4core5stdio4selfFZv ();
    _Y4core5array4selfFZv ();
    _Y3std6traits4selfFZv ();
    _Y3std6string4selfFZv ();
    _Y3std4math4selfFZv ();
    _Y3std9algorithm11comparaison4selfFZv ();
    _Y3std9algorithm9searching4selfFZv ();
    _Y3std5array4selfFZv ();
    _Y3std5stdio1_4selfFZv ();
    _Y3std5stdio5print4selfFZv ();
    _Y3std5stdio4file4selfFZv ();
    _Y3std4conv4selfFZv ();
    _Y3sdl4selfFZv ();
    _Y5input4selfFZv ();
    _Y3std3map4selfFZv ();
    _Y6signal4selfFZv ();
    _Y3sdl4selfFZv ();
    _Y3app4selfFZv ();
    _Y3app7connectFR26STSignal33NtupleNintU32ubyteNNf_TiubZv (_Y5input8keyboardF11ESDL_KeycodeZR26STSignal33NtupleNintU32ubyteNN (cast (int) (cast (int) (cast (char) (27)))), (&(_Y3app3endFTiubZv)));
    _Y3app7connectFR38STSignal33NtupleNubyteU32intU32intU32ubyteNNf_TubiiubZv (_Y5input5mouseF10ESDL_ButtonZR38STSignal33NtupleNubyteU32intU32intU32ubyteNN (cast (int) (1)), (&(_Y3app4testFTubiiubZv)));
    _Y3app7connectFR38STSignal33NtupleNubyteU32intU32intU32ubyteNNf_TubiiubZv (_Y5input5mouseF10ESDL_ButtonZR38STSignal33NtupleNubyteU32intU32intU32ubyteNN (cast (int) (3)), (&(_Y3app4testFTubiiubZv)));
    _Y3app7connectFR16STSignal33NtupleNNNf_TZv (_Y5input4quitFZR16STSignal33NtupleNNN (), (&(_Y3app4QuitFTZv)));
     ST3sdlWindow * win = _Y3sdl7initSDLFcsiiZ6STWindow (Tuple!(ulong, char*) (4, cast (char*) (("Test").ptr)), cast (int) (800), cast (int) (600));

    while (cast (bool) ((!(END)) && (!(_Y5input4pollFZb ()))))  {
        _Y3sdl5clearF6STWindowZv (win);
        _Y3sdl10swapWindowF6STWindowZv (win);
    }
}

void _Y3app4selfFZv () {
    END = false;
}
