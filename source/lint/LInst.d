module lint.LInst;
import lint.LExp, syntax.Word;

class LInst {    
    Location locus;
    abstract LExp getFirst ();    
}
