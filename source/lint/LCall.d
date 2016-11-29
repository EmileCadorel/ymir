module lint.LCall;
import lint.LExp;
import std.container, std.outbuffer, std.conv;

class LCall : LExp {

    private string _frame;
    private Array!LExp _params;
    private int _size;
    
    this (string frame, Array!LExp params, int size) {
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

    override int size () {
	return this._size;
    }
    
    override bool isInst () {
	return true;
    }
    
}
