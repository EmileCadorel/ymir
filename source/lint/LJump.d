module lint.LJump;
import lint.LInst, lint.LExp, lint.LLabel;
import std.outbuffer;

class LJump : LInst {

    private LExp _test;
    private LLabel _lbl1;
    private LLabel _lbl2;

    this (LExp test, LLabel lbl1, LLabel lbl2) {
	this._test = test;
	this._lbl1 = lbl1;
	this._lbl2 = lbl2;
    }
    
    this (LExp test, LLabel lbl1) {
	this._test = test;
	this._lbl1 = lbl1;
	this._lbl2 = null;
    }
    
}
