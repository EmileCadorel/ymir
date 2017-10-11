module ymir.dtarget.DFor;
import ymir.dtarget._;

import std.outbuffer;

class DFor : DInstruction {

    private DVar _var;

    private DExpression _test;

    private DExpression _iter;
    
    private DBlock _block;

    this (DVar var, DExpression test, DExpression iter, DBlock bl) {
	this._var = var;
	this._test = test;
	this._iter = iter;
	this._block = bl;
    }

    ref DBlock block () {
	return this._block;
    }    

    ref static ulong nb () {
	static ulong __nb__ = 0;
	return __nb__;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	this._block.nbIndent = this._father.nbIndent + 4;
	buf.writef ("for (ulong %s = 0 ; %s ; %s) %s",
		    this._var.toString,
		    this._test.toString,
		    this._iter.toString,
		    this._block.toString);
		    
	return buf.toString;
    }

} 
