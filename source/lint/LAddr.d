module lint.LAddr;
import lint.LExp;

class LAddr : LExp {

    private LExp _exp;

    this (LExp what) {
	this._exp = what;
    }
        
}
