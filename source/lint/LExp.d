module lint.LExp;
import lint.LInst, lint.LSize;
import std.stdio;

class LExp : LInst {    
    
    abstract bool isInst ();
    
    override final LExp getFirst () {
	return this;
    }

    LSize size () {
	assert (false, typeid (this).toString());
    }
    
}
