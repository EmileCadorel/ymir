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
	return LSize.ULONG;
    }
    
    override bool isInst () {
	return false;
    }
    
    override string toString () {
	if (!this._exp) return "&(ERROR)";
	return "&(" ~ this._exp.toString ~ ")";
    }

}
