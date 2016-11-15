module lint.LRegRead;
import lint.LExp, lint.LReg;
import std.outbuffer, std.conv;

class LRegRead : LExp {

    private LReg _data;
    private ulong _begin;
    private int _size;

    this (LReg reg) {
	this._data = reg;
	this._begin = 0;
	this._size = reg.size;
    }
    
    this (LReg str, ulong begin, int size) {
	this._data = str;
	this._begin = begin;
	this._size = size;
    }

    ref LReg data () {
	return this._data;
    }

    ref ulong begin () {
	return this._begin;
    }

    override int size () {
	return this._size;
    }

    override bool isInst () {
	return false;
    }
    
    override string toString () {
	return '{' ~ this._data.toString () ~ "}["
	    ~ to!string (this._begin) ~ ":" ~ to!string (this._size) ~ "]";
    }
    
}
