module lint.LCall;
import lint.LExp, lint.LSize;
import std.container, std.outbuffer, std.conv;

class LCall : LExp {

    private string _frame;
    private Array!LExp _params;
    private LSize _size;
    private LExp _dynFrame;


    this (LExp dyn, Array!LExp params, LSize size) {
	this._dynFrame = dyn;
	this._params = params;
	this._size = size;
	this._frame = null;
    }
    
    this (string frame, Array!LExp params, LSize size) {
	this._frame = frame;
	this._params = params;
	this._size = size;
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

    override LSize size () {
	return this._size;
    }
    
    override bool isInst () {
	return true;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("Call(%s, [",
		    this._frame !is null ? this._frame : this._dynFrame.toString);
	foreach (it ; this._params) {
	    if (it !is this._params [$ - 1])
		buf.writef ("%s, ", it);
	    else  buf.writef ("%s", it);
	}
	buf.writef("], %s)\n", to!string (this._size));
	return buf.toString ();
    }
    
}
