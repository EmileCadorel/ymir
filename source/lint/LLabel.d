module lint.LLabel;
import lint.LInst, lint.LExp;
import std.conv : to;

class LLabel : LInst {

    private static ulong __last__ = 0;
    private static ulong [ulong] __renamed__;

    private ulong _id;
    private string _name;

    this () {
	this._id = __last__;
	__last__ ++;
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

    override string toString () {
	return "lbl:" ~ to!string (this._id);
    }
    
}
