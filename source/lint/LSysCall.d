module lint.LSysCall;
import lint.LExp, std.container;
import std.outbuffer;

class LSysCall : LExp {

    private string _name;
    private Array!LExp _params;
    private LExp _ret;

    this (string name, Array!LExp params, LExp ret) {
	this (name, params);
	this._ret = ret;
    }
    
    this (string name, Array!LExp params) {
	this._name = name;
	this._params = params;
    }
    
    string name () {
	return this._name;
    }

    LExp ret () {
	return this._ret;
    }
    
    Array!LExp params () {
	return this._params;
    }
    
    override bool isInst () {
	return true;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("sysCall(%s, [", this._name);
	foreach (it ; this._params) {
	    if (it !is this._params [$ - 1])
		buf.writef ("%s, ", it);
	    else  buf.writef ("%s", it);
	}
	buf.writef("]) -> %s", this._ret);
	return buf.toString ();
    }
    
}

