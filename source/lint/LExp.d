module lint.LExp;
import lint.LInst;
import std.stdio;

class LExp : LInst {

    abstract bool isInst ();
    
    override final LExp getFirst () {
	return this;
    }

    int size () {
	assert (false, typeid (this).toString());
    }
    
}
