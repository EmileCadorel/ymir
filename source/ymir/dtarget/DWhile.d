module ymir.dtarget.DWhile;
import ymir.dtarget._;

import std.outbuffer;

class DWhile : DInstruction {

    private DExpression _test;

    private DBlock _block;

    this (DExpression test, DBlock bl) {
	this._test = test;
	this._block = bl;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	this._block.nbIndent = this._father.nbIndent + 4;
	buf.writef ("while (%s) %s", this._test.toString, this._block.toString);
	return buf.toString;
    }

}
 
