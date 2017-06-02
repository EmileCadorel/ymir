module lint.LReg;
import lint.LExp, lint.LSize;
import std.conv;

class LReg : LExp {
    
    private static ulong __last__ = 0;
    private ulong _id;
    private LSize _size;
    private string _name;
    private string _value;
    private ulong _length;
    private bool _isStatic;
    private bool _scoped;
    
    this (LSize size) {
	this._id = __last__;
	__last__ ++;
	this._size = size;
    }

    this (ulong id, LSize size) {
	this._id = id;
	this._size = size;
    }

    this (ulong id, LSize size, bool scoped) {
	this._id = id;
	this._size = size;
	this._scoped = true;
    }
    
    this (ulong id, LSize size, string name, string value) {
	this._id = id;
	this._size = size;
	this._isStatic = true;
	this._name = name;
	this._value = value;
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

    bool isStatic () {
	return this._isStatic;
    }

    string name () {
	return this._name;
    }

    string value () {
	return this._value;
    }
    
    override bool isInst () {
	return false;
    }
    
    override LSize size () {
	return this._size;
    }
    
    override string toString () {
	import std.format;
	return format("#%d", this._id);
    }
    
}
