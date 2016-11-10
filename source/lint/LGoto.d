module lint.LGoto;
import lint.LInst, lint.LLabel, lint.LExp;
import std.outbuffer;

class LGoto : LInst {
    private LLabel _lbl;

    this (LLabel lbl) {
	this._lbl = lbl;
    }

    LLabel lbl () {
	return this._lbl;
    }
    
    override LExp getFirst () {
	assert (false, "fatal error");
    }

    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writefln ("goto %s", this._lbl.toSimpleString ());
	return buf.toString ();
    }
    
}
