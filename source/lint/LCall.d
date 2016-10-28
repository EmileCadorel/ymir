module lint.LCall;
import lint.LExp;
import std.container, std.outbuffer, std.conv;

class LCall : LExp {

    private string _frameName;
    private LExp _frameReg = null;
    private short _size;
    private Array!LExp _params;
    private Array!short _lengths;
    
    this (string frame, short size, Array!LExp params, Array!short lengths) {
	this._size = size;
	this._frameName = frame;
	this._params = params;
	this._lengths = lengths;
    }

    this (LExp frame, short size, Array!LExp params, Array!short lengths) {
	this._size = size;
	this._frameReg = frame;
	this._params = params;
	this._lengths = lengths;
    }
        
}
