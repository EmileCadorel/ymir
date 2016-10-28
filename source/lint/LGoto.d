module lint.LGoto;
import lint.LInst, lint.LLabel;
import std.outbuffer;

class LGoto : LInst {
    private LLabel _lbl;

    this (LLabel lbl) {
	this._lbl = lbl;
    }
}
