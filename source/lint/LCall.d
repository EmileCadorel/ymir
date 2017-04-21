module lint.LCall;
import lint.LExp, lint.LSize;
import std.container, std.outbuffer, std.conv;

class LCall : LExp {

    private string _frame;
    private string _un;
    private Array!LExp _params;
    private LSize _size;
    private LExp _dynFrame;
    private bool _isVariadic;

    this (LExp dyn, Array!LExp params, LSize size, bool variadic = false) {
	this._dynFrame = dyn;
	this._params = params;
	this._size = size;
	this._frame = null;
	this._isVariadic = variadic;
    }
    
    this (string frame, string un, Array!LExp params, LSize size, bool variadic = false) {
	this._frame = frame;
	this._un = un;
	this._params = params;
	this._size = size;
	this._isVariadic = variadic;
    }
    
    this (string frame, Array!LExp params, LSize size, bool variadic = false) {
	this._frame = frame;
	this._params = params;
	this._size = size;
	this._isVariadic = variadic;
    }

    
    LExp dynFrame () {
	return this._dynFrame;
    }

    Array!LExp params () {
	return this._params;
    }

    string name () {
	return this._frame;
    }

    string un () {
	return this._un;
    }
    
    override LSize size () {
	return this._size;
    }
    
    override bool isInst () {
	return true;
    }

    bool isVariadic () {
	return this._isVariadic;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("Call(%s, [",
		    this._frame !is null ?
		         (this._un != "" ? this._un : this._frame)
		         : this._dynFrame.toString);
	foreach (it ; this._params) {
	    if (it !is this._params [$ - 1])
		buf.writef ("%s,\n\t\t\t", it);
	    else  buf.writef ("%s", it);
	}
	buf.writef("], %s)\n", to!string (this._size));
	return buf.toString ();
    }
    
}
