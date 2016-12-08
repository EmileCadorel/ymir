module lint.LLabel;
import lint.LInst, lint.LExp, lint.LInstList;
import std.conv, std.outbuffer;

class LLabel : LInst {

    private static ulong __last__ = 0;
    private static ulong [ulong] __renamed__;

    private ulong _id;
    private string _name;
    private LInstList _insts;
    
    this () {
	this._id = __last__;
	__last__ ++;
    }

    this (LInstList list) {
	this._insts = list;
	this._id = __last__;
	__last__++;
    }
    
    this (ulong id) {
	this._id = __rename__ (id);
    }

    override LExp getFirst () {
	return null;
    }
    
    private static ulong __rename__ (ulong id) {
	auto elem = (id in __renamed__);
	if (elem !is null) {
	    return *elem;
	} else {
	    __renamed__ [id] = lastId;
	    return __renamed__ [id];
	}
    }

    static void clear () {
	__renamed__ .destroy;
    }
    
    static ulong lastId () {
	ulong ret = __last__;
	__last__ ++;
	return ret;
    }

    ulong id () {
	return this._id;
    }

    ref LInstList insts () {
	return this._insts;
    }

    string toSimpleString () {
	return "lbl" ~ to!string (this._id);
    }
    
    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("lbl%s:", this._id);
	if (this._insts !is null)
	    buf.write (this._insts.toString ());
	else buf.writefln ("");
	return buf.toString ();
    }
    
}
