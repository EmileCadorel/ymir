module lint.LCast;
import lint.LExp;

class LCast : LExp {
    
    private LExp _what;
    private ushort _from;
    private ushort _to;

    this (LExp what, ushort from, ushort to) {
	this._what = what;
	this._from = from;
	this._to = to;
    }
    
}

