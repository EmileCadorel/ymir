module ymir.lint.LDelete;
import ymir.lint._;

import std.outbuffer;

class LDelete : LInst {

    private LExp _who;

    this (LExp who) {
	this._who = who;
    }

}
