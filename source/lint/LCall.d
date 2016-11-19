module lint.LCall;
import lint.LExp;
import std.container, std.outbuffer, std.conv;

class LCall : LExp {

    private string _frame;
    private Array!LExp _params;
    
    this (string frame, Array!LExp params) {
	this._frame = frame;
	this._params = params;
    }

    Array!LExp params () {
	return this._params;
    }

    string name () {
	return this._frame;
    }
    
    override bool isInst () {
	return true;
    }
    
}
