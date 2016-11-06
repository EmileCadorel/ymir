module target.TReg;
import std.conv;

class TReg {

    private ulong _id;
    private int _size;
    
    this (ulong id, int size) {
	this._id = id;
	this._size = size;
    }
    
    override string toString () {
	return "$("
	    ~ to!string (this._id)
	    ~ ":"
	    ~ to!string (this._size)
	    ~ ")";
    }

}
