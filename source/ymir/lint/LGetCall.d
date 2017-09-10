module ymir.lint.LGetCall;
import ymir.lint._;

import std.outbuffer;

class LGetCall : LInst {

    private LExp _where = null;
    private LCall _call;

    this (LExp where, LCall call) {
	this._where = where;
	this._call = call;
    }

    this (LCall call) {
	this._call = call;	
    }    

}
