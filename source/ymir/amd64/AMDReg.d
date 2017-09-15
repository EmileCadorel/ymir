module ymir.amd64.AMDReg;
import ymir.amd64.AMDSize, ymir.amd64.AMDConst, std.typecons;
import ymir.utils.Singleton, std.container, ymir.amd64.AMDObj;
import ymir.amd64.AMDRegTable;
import std.conv, std.outbuffer;
import std.math;


alias R = Tuple!(AMDSize, "size", string, "name");

class AMDRegInfo {
    
    private R [] _subs;
    private AMDReg _reg;
    private string _name;

    this (string name, R [] subs) {
	this._name = name;
	this._subs = subs;
    }

    this (AMDReg reg) {
	this._reg = reg;
    }

    string name () {
	return this._subs [0].name;
    }
    
    R* opBinaryRight (string op : "in") (AMDSize size) {
	foreach (ref it ; this._subs) {
	    if (it.size == size) return &it;
	}
	return null;
    }
    
    bool opBinaryRight (string op : "in") (string name) {
	foreach (value ; this._subs) {
	    if (value.name == name) return true;
	}
	return false;
    }
    
    override bool opEquals (T : Object) (T other) {
	if (name is null) return reg == other;
	else {
	    if (other is null) return false;
	    else if (other.name == name) return true;
	}
	return false;
    }
    
    static R empty (AMDSize size) {
	return R (size, null);
    }	
}


class AMDReg : AMDObj {

    private AMDSize _size;
    private ulong _id;
    private string _name;
    private bool _isStd = false;
    private bool _isOff = false;
    private bool _pos = false;
    private long _offset;
    static long __globalOffset__ = 0;   
    static long [ulong] __offsets__;
    static ulong __lastId__;
    
    protected this () {}

    this (R info) {
	if (info.name !is null) {
	    this._isStd = true;
	    this._name = info.name;
	    this._size = info.size;
	} else {
	    this._isStd = false;
	    this._id = lastId ();
	    this._size = info.size;
	    this.toAsm ();
	}
    }
    
    this (ulong id, AMDSize size) {
	this._isStd = false;
	this._id = id;
	this._size = size;
	this.toAsm ();
    }

    this (AMDSize size) {
	this._isStd = false;
	this._id = lastId ();
	this._size = size;
	this.toAsm ();
    }

    this (AMDSize size, long offset) {
	this._isStd = true;
	this._id = lastId ();
	this._size = size;
	this._offset = offset;
	__offsets__ [this._id] = offset;
	this._isOff = true;
	this._pos = true;
	auto r = REG.getReg ("rbp");
	this._name = r.name;
    }

    this (ulong id, AMDSize size, long offset) {
	this._isStd = true;
	this._id = id;
	this._size = size;
	this._offset = offset;
	__offsets__ [this._id] = offset;
	this._isOff = true;
	this._pos = true;
	auto r = REG.getReg ("rbp");
	this._name = r.name;
    }

    
    this (string name, AMDSize size) {
	this._isStd = true;
	this._name = name;
	this._size = size;
    }

    ref long offset () {
	return this._offset;
    }
    
    ref bool isOff () {
	return this._isOff;
    }

    ref bool isStd () {
	return this._isStd;
    }
    
    ref string name () {
	return this._name;
    }

    override bool opEquals (Object other) {
	auto reg = cast (AMDReg) other;
	if (!reg) return false;
	else {
	    if (this._isOff) {
		if (!reg._isOff || reg._offset != this._offset || this._name != reg._name || reg._pos != this._pos)
		    return false;
		return true;
	    } else if (this._isStd) {
		if (!reg._isStd || reg._name != this._name) return false;
		return true;	
	    } else return reg._id == this._id;
	}
    }
    
    static ulong globalOff () {
	return __globalOffset__;
    }
    
    static void lastId (ulong last) {
	__lastId__ = last;
    }

    static ulong lastId () {
	auto id = __lastId__;
	__lastId__++;
	return id;
    }
    
    static ulong reserveLength (ulong length) {
	long o;
	auto res = __globalOffset__ % AMDSize.QWORD.size;
	if (res != 0) {
	    res = (AMDSize.QWORD.size - res);
	    __globalOffset__ += res;
	}
	__globalOffset__ += length;
	o = __globalOffset__;
	return o;
    }
    
    private void toAsm () {
	if (this._isStd) return;
	auto off = this._id in __offsets__;
	long o;
	if (off is null) {
	    auto res = __globalOffset__ % this._size.size;
	    if (res  != 0) {
		res =  (this._size.size - res);
		__globalOffset__ += res;
	    }
	    o = __globalOffset__ + abs (this._size.size);
	    __offsets__ [this._id] = o;
	    __globalOffset__ = o;
	} else o = *off;
	auto r = REG.getReg ("rbp");
	this._isStd = true;
	this._offset = o;
	this._name = r.name;
	this._isOff = true;	
    }

    static void resetOff () {
	long[ulong] aux;
	__offsets__ = aux;
	__globalOffset__ = 0;
    }
    
    void resize (AMDSize size) {	
	if (this._isStd && !this._isOff) {
	    auto info = REG.getReg (this._name, size);
	    this._name = info.name;
	    this._size = info.size;	    
	} else {
	    this._size = size;
	}
    }
       
    AMDReg clone (AMDSize size) {
	if (this._isStd && !this._isOff) {	    
	    return new AMDReg (REG.getReg (this._name, size));
	} else {
	    return new AMDReg (this._id, size);
	}
    }
    
    override AMDSize sizeAmd () {
	return this._size;
    }

    override string toString () {
	auto buf = new OutBuffer;
	if (this._isStd) {
	    if (this._isOff && this._offset != 0) {
		if (!this._pos)
		    return to!string (-this._offset) ~ "(%" ~ this._name ~ ")";
		else
		    return to!string (this._offset) ~ "(%" ~ this._name ~ ")";
	    } else if (this._isOff) {
		return "(%" ~ this._name ~ ")";
	    } else return "%" ~ this._name;
	}
	return "%tr:" ~ to!string (this._id) ~ ":" ~ to!string (this._size);
    }
   
}

alias REG = AMDRegTable.instance;
