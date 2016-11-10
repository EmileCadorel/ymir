module lint.LSysCall;
import lint.LExp, std.container;

class LSysCall : LExp {

    private string _name;
    private Array!LExp _params;
    
    this (string name, Array!LExp params) {
	this._name = name;
	this._params = params;
    }

    string name () {
	return this._name;
    }

    Array!LExp params () {
	return this._params;
    }
    
    override bool isInst () {
	return true;
    }
    
}

