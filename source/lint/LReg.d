module lint.LReg;
import lint.LData;
import std.conv;

class LReg : LData {
    
    private static ulong __last__ = 0;
    private ulong _id;
    private int _size;
    private string _name;
    private ulong _length;

    this (int size) {
	this._id = __last__;
	__last__ ++;
	this._size = size;
    }

    this (ulong id, int size) {
	this._id = id;
	this._size = size;
    }
    
    static ulong lastId () {
	ulong ret = __last__;
	__last__ ++;
	return ret;
    }

    override int size () {
	return this._size;
    }
    
    override string toString () {
	return "reg(" ~ to!string (this._id) ~ ":" ~ to!string (this._size) ~ ")";
    }
    
}
