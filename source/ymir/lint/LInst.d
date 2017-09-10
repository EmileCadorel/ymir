module ymir.lint.LInst;
import ymir.lint._;
import ymir.syntax._;

class LInst {    
    Location locus;
    abstract LExp getFirst ();    
}
