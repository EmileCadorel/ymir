module ymir.dtarget.DFor;
import ymir.dtarget._;

import std.outbuffer, std.string;

class DFor : DInstruction {

    private DVarDecl _inits;
    
    private DExpression _test;
    
    private DExpression _iter;
    
    private DBlock _block;

    this (DVarDecl var, DExpression test, DExpression iter, DBlock bl) {
	this._inits = var;
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
	this._inits.father = this._father;	
	buf.writef ("%s%sfor (; %s ; %s) %s",		    
		    this._inits.toString,
		    rightJustify ("", this._father.nbIndent, ' '),
		    this._test.toString,
		    this._iter.toString,
		    this._block.toString);
		    
	return buf.toString;
    }

} 
