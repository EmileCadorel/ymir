module lint.LLocus;
import syntax.Word, lint.LInst, lint.LExp;
import std.conv;

class LLocus : LInst {

    protected Location _locus;
    
    this (Location locus) {
	this._locus = locus;
    }

    override LExp getFirst () {
	assert (false);
    }

    ref Location locus () {
	return this._locus;
    }
    
    override string toString () {
	//return to!string (this._locus) ~ "\n";
	return "";
    }
    
}
