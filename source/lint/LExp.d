module lint.LExp;
import lint.LInst;
import std.stdio;

class LExp : LInst {

    override final LExp getFirst () {
	return this;
    }

}
