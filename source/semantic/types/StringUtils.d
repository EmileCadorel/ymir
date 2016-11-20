module semantic.types.StringUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens;

class StringUtils {


    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	if (auto _str = cast(LConstString) rightExp) {
	    inst += llist;
	    auto size = _str.value.length;
	    inst += (new LSysCall ("alloc", make!(Array!LExp)(new LConstQWord (size + 8)), leftExp));
	    inst += new LWrite (new LRegRead (cast (LReg)leftExp, 0, 8), new LConstQWord (size));
	    foreach (it ; 0 .. size) {
		inst += (new LWrite (new LRegRead (cast(LReg)leftExp, it + 8, 1), new LConstByte (_str.value [it])));
	    }
	} else {
	    inst += llist + rlist;
	    inst += new LWrite (leftExp, rightExp);
	}
	return inst;
    }

    static LInstList InstAccessS (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto aux = new LReg (8);
	inst += new LBinop (leftExp, rightExp, aux, Tokens.PLUS);
	inst += new LBinop (new LConstQWord (8), aux, aux, Tokens.PLUS);
	inst += new LRegRead (aux, 0, 1);
	return inst;
    }
    
    

}
