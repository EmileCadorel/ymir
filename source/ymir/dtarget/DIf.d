module ymir.dtarget.DIf;
import ymir.dtarget._;

import std.outbuffer;

class DIf : DInstruction {

    private DExpression _test;

    private DBlock _bl;
    
    private DIf _delse;

    this (DExpression expr, DBlock bl, DIf delse = null) {
	this._test = expr;
	this._bl = bl;
	this._delse = delse;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	this._bl.nbIndent = this._father.nbIndent + 4;
	if (this._test) {
	    buf.writef ("if (%s)%s", this._test.toString, this._bl.toString);
	    if (this._delse) {
		this._delse._father = this._father;
		buf.writef (" else %s", this._delse.toString);
	    }
	} else {
	    buf.writef ("%s", this._bl.toString);
	}
	return buf.toString;
    }          
}

