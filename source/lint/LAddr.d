module lint.LAddr;
import lint.LExp;

class LAddr : LExp {

    private LExp _exp;

    this (LExp what) {
	this._exp = what;
    }

    LExp exp () {
	return this._exp;
    }

    override int size () {
	return this._exp.size ();
    }
    
    override bool isInst () {
	return false;
    }
    
}
