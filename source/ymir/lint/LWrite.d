module ymir.lint.LWrite;
import ymir.lint._;

import std.outbuffer, std.conv, std.stdio;

class LWrite : LInst {
    private LExp _left;
    private LExp _right;
    private long _size;

    this (LExp left, LExp right) {
	this._left = left;
	this._right = right;
    }
    
    this (LExp left, LExp right, long size) {
	this._left = left;
	this._right = right;
	this._size = size;
    }    
    
    override LExp getFirst () {
	return this._left;
    }

    ref LExp left () {
	return this._left;
    }

    ref LExp right () {
	return this._right;
    }    
    
    override string toString () {
	auto buf = new OutBuffer;
	buf.writef ("%s := %s",
		      this._left.toString (),
		      this._right.toString ());
	
	return buf.toString ();
    }
    
}


  
