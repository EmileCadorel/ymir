module lint.LAddr;
import lint.LExp, lint.LSize;

class LAddr : LExp {

    private LExp _exp;

    this (LExp what) {
	this._exp = what;
    }

    LExp exp () {
	return this._exp;
    }

    override LSize size () {
	return LSize.LONG;
    }
    
    override bool isInst () {
	return false;
    }
    
    override string toString () {
	return "&(" ~ this._exp.toString ~ ")";
    }

}
