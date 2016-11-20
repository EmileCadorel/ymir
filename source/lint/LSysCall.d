module lint.LSysCall;
import lint.LExp, std.container;

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
    
}

