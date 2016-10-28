module lint.LDelete;
import lint.LInst, lint.LExp;
import std.outbuffer;

class LDelete : LInst {

    private LExp _who;

    this (LExp who) {
	this._who = who;
    }

}
