module ybyte.YBReg;
import std.conv, target.TExp, target.TReg;

class YBReg : TReg {  

    private ulong _id;
    private int _size;
    
    this (ulong id, int size) {
	this._id = id;
	this._size = size;
    }

    override int size () {
	return this._size;
    }
    
    override string toString () {
	return "$" ~ to!string (this._id);
    }

}
