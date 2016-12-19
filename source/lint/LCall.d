module lint.LCall;
import lint.LExp, lint.LSize;
import std.container, std.outbuffer, std.conv;

class LCall : LExp {

    private string _frame;
    private Array!LExp _params;
    private LSize _size;
    
    this (string frame, Array!LExp params, LSize size) {
	this._frame = frame;
	this._params = params;
	this._size = size;
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
	buf.writef ("Call(%s, [", this._frame);
	foreach (it ; this._params) {
	    if (it !is this._params [$ - 1])
		buf.writef ("%s, ", it);
	    else  buf.writef ("%s", it);
	}
	buf.writef("])\n");
	return buf.toString ();
    }

    
}
