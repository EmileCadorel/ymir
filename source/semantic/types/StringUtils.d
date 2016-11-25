module semantic.types.StringUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;

class StringUtils {

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LWrite (leftExp, rightExp);
	inst += new LBinop (new LRegRead (cast (LReg)leftExp, 0, 8), new LConstQWord (1), new LRegRead (cast (LReg)leftExp, 0, 8), Tokens.PLUS); // Nb ref	
	return inst;
    }

    static LInstList InstAccessS (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto aux = new LReg (8);
	inst += new LBinop (leftExp, rightExp, aux, Tokens.PLUS);
	inst += new LBinop (new LConstQWord (16), aux, aux, Tokens.PLUS);
	inst += new LRegRead (aux, 0, 1);
	return inst;
    }
    
    static LInstList InstLength (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	if (auto str = (cast(LConstString) leftExp)) {
	    inst += new LConstQWord (str.value.length);
	} else {
	    inst += new LRegRead (cast (LReg) leftExp, 8, 8);
	}
	return inst;
    }

    static LInstList InstDestruct (LInstList llist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (new LRegRead (cast (LReg) leftExp, 0, 8),
			    new LConstQWord (1),
			    new LRegRead (cast (LReg) leftExp, 0, 8), Tokens.MINUS);
	
	LLabel faux = new LLabel ();
	LLabel vrai = new LLabel ();
	LLabel fin = new LLabel ();
	inst += new LJump (new LRegRead (cast (LReg) leftExp, 0, 8), faux);
	inst += new LGoto (vrai);
	vrai.insts = new LInstList ();
	vrai.insts += new LSysCall ("free", make!(Array!LExp) (leftExp));	
	vrai.insts += new LGoto (fin);
	faux.insts = new LInstList (new LGoto (fin));
	inst += vrai;
	inst += faux;
	inst += fin;
	return inst;
    }
    
    static LInstList InstDup (LInstList left, LInstList llist) {
	auto inst = new LInstList;
	auto aux = left.getFirst (), leftExp = llist.getFirst ();
	inst += llist;
	auto size = new LReg (8);
	inst += new LBinop (new LRegRead (leftExp, 8, 8),
			    new LConstQWord (16), size, Tokens.PLUS);
	
	inst += new LSysCall ("alloc", make!(Array!LExp) (size), aux);
	inst += (new LWrite (new LRegRead (aux, 0, 8),  new LConstQWord (1)));
	
	inst += (new LWrite (new LRegRead (aux, 8, 8), new LRegRead (leftExp, 8, 8)));

	auto i = new LReg (8);
	inst += new LWrite (i, new LRegRead (leftExp, 8, 8));
	auto faux = new LLabel, vrai = new LLabel, debut = new LLabel;
	faux.insts = new LInstList;
	vrai.insts = new LInstList ();
	debut.insts = new LInstList;
	inst += debut;
	inst += new LJump (i, vrai);
	inst += new LGoto (faux);
	vrai.insts += new LWrite (new LRegRead (new LBinop (aux, new LBinop (i, new LConstQWord (15), Tokens.PLUS), Tokens.PLUS), 0, 8),
				  new LRegRead (new LBinop (leftExp, new LBinop (i, new LConstQWord (15), Tokens.PLUS), Tokens.PLUS), 0, 8));
	
	vrai.insts += new LBinop (i, new LConstQWord (1), i, Tokens.MINUS);
	vrai.insts += new LGoto (debut);
	inst += vrai;
	inst += faux;
	inst += aux;
	return inst;
    }


    
}
