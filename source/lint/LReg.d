module lint.LReg;
import lint.LExp, lint.LSize;
import std.conv;

class LReg : LExp {
    
    private static ulong __last__ = 0;
    private ulong _id;
    private LSize _size;
    private string _name;
    private ulong _length;

    this (LSize size) {
	this._id = __last__;
	__last__ ++;
	this._size = size;
    }

    this (ulong id, LSize size) {
	this._id = id;
	this._size = size;
    }
    
    static ulong lastId () {
	ulong ret = __last__;
	__last__ ++;
	return ret;
    }

    static void lastId (ulong last) {
	__last__ = last;
    }

    ulong id () {
	return this._id;
    }

    override bool isInst () {
	return false;
    }
    
    override LSize size () {
	return this._size;
    }
    
    override string toString () {
	return "reg(" ~ to!string (this._id) ~ ":" ~ to!string (this._size) ~ ")";
    }
    
}
