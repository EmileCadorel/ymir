module ymir.dtarget.DWhile;
import ymir.dtarget._;

import std.outbuffer;

class DWhile : DInstruction {

    private DExpression _test;

    private DBlock _block;

    private string _name;
    
    this (DExpression test, DBlock bl) {
	this._test = test;
	this._block = bl;
    }

    ref string name () {
	return this._name;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	this._block.nbIndent = this._father.nbIndent + 4;
	buf.writef ("%swhile (%s) %s", this._name != "" ? this._name ~ ":" : "",
		    this._test.toString, this._block.toString);
	
	return buf.toString;
    }

}
 
