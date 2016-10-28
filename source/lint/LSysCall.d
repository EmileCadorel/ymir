module lint.LSysCall;
import lint.LExp, std.container;

class LSysCall : LExp {

    private Array!LExp _params;
    
    this (Array!LExp params) {
	this._params = params;
    }
    
}

