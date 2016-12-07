module semantic.types.StringUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCall, lint.LFrame, lint.LCast, lint.LAddr;

class StringUtils {

    static immutable string __CstName__ = "_YPCstString";
    static immutable string __DstName__ = "_YPDstString";
    static immutable string __AddRef__ = "_YPAddRefString";

    static void createAddRef () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (8);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (addr, 0, 8), new LConstQWord (0), Tokens.NOT_EQUAL);
	auto vrai = new LLabel, faux = new LLabel;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	vrai.insts = new LInstList;
	vrai.insts += new LWrite (new LRegRead (new LRegRead (addr, 0, 8), 0, 4),
				  new LBinop (new LRegRead (new LRegRead (addr, 0, 8), 0, 4),
					      new LConstDWord (1), Tokens.PLUS));
	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__AddRef__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__AddRef__] = fr;
	LReg.lastId = last;
    }
    
    static void createDstString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (8);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += new LWrite (new LRegRead (addr, 0, 4), new LBinop (new LConstDWord (1), new LRegRead (addr, 0, 4), Tokens.MINUS));
	auto test = new LBinop (new LRegRead (addr, 0, 4), new LConstDWord (0), Tokens.INF_EQUAL);
	auto vrai = new LLabel, faux = new LLabel;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	vrai.insts = new LInstList;
	vrai.insts += new LSysCall ("free", make!(Array!LExp) ([addr]));
	vrai.insts += new LGoto (faux);
	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__DstName__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__DstName__] = fr;
	LReg.lastId = last;
    }

    static void createCstString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (4);
	auto addr = new LReg (8);
	Array!LReg args = make!(Array!LReg) (size, addr);
	auto retReg = new LReg (8);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (size, new LConstDWord (9), Tokens.PLUS)]), retReg));
	auto index = new LReg (8);
	entry.insts += (new LWrite (new LRegRead (retReg, 0, 4), new LConstDWord (1))); // Une reference, le symbol ""
	entry.insts += (new LWrite (new LRegRead (retReg, 4, 4), size));
	entry.insts += (new LWrite (index, new LConstQWord (8)));
	auto test = new LBinop (new LRegRead (addr, 0, 1), new LConstByte (0), Tokens.NOT_EQUAL);
	auto debut = new LLabel (), vrai = new LLabel, faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

	vrai.insts = new LInstList;
	auto access = new LRegRead (new LBinop (retReg, index, Tokens.PLUS), 0, 1);
	vrai.insts += new LWrite (access, new LRegRead (addr, 0, 1));
	vrai.insts += new LBinop (addr, new LConstQWord (1), addr, Tokens.PLUS);
	vrai.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai.insts += new LGoto (debut);
	
	entry.insts += vrai;
	entry.insts += faux;

	
	LReg.lastId = last;
	auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	LFrame.preCompiled [__CstName__] = fr;
    }

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstString (inst, leftExp, cst);
	inst += new LWrite (new LRegRead (cast (LReg)rightExp, 0, 4), new LBinop (new LConstDWord (1), new LRegRead (cast (LReg)rightExp, 0, 4), Tokens.PLUS)); // Nb ref
	auto it = (__DstName__ in LFrame.preCompiled);
	if (it is null) {
	    createDstString ();
	}
	inst += new LCall (__DstName__, make!(Array!LExp) ([leftExp]), 0);
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstString (inst, leftExp, cst);
	inst += new LWrite (new LRegRead (cast (LReg)rightExp, 0, 4), new LBinop (new LConstDWord (1), new LRegRead (cast (LReg)rightExp, 0, 4), Tokens.PLUS)); // Nb ref
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }
    
    private static LInstList affectConstString (LInstList inst, LExp leftExp, LConstString rightExp) {
	Array!LExp exps;
	exps.insertBack (new LConstQWord (rightExp.value.length));
	exps.insertBack (rightExp);
	auto it = (__CstName__ in LFrame.preCompiled);
	if (it is null) {
	    createCstString ();
	}
	inst += new LWrite (leftExp, new LCall (__CstName__, exps, 8));
	inst += new LWrite (new LRegRead (cast (LReg) leftExp, 0, 4), new LBinop (new LConstDWord (1), new LRegRead (cast (LReg) leftExp, 0, 4), Tokens.PLUS));
	return inst;
    }
    
    static LInstList InstAccessS (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto aux = new LReg (8);
	inst += new LBinop (leftExp, new LCast (rightExp, 8), aux, Tokens.PLUS);
	inst += new LBinop (new LConstQWord (8), aux, aux, Tokens.PLUS);
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
	    inst += new LRegRead (cast (LReg) leftExp, 4, 4);
	}
	return inst;
    }

    static LInstList InstNbRef (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	if (auto str = (cast(LConstString) leftExp)) {
	    inst += new LConstQWord (0);
	} else {
	    inst += new LRegRead (cast (LReg) leftExp, 0, 4);
	}
	return inst;
    }
    
    static LInstList InstDestruct (LInstList llist) {
	auto it = (__DstName__ in LFrame.preCompiled);
	if (it is null) {
	    createDstString ();
	}
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	inst += new LCall (__DstName__, make!(Array!LExp) ([expr]), 0);
	return inst;
    }
    
    static LInstList InstDup (LInstList left, LInstList llist) {
	assert (false);
    }

    static LInstList InstParam (LInstList llist) {
	auto leftExp = llist.getFirst ();
	auto it = (__AddRef__ in LFrame.preCompiled);
	if (it is null) {
	    createAddRef ();
	}
	llist += new LCall (__AddRef__, make! (Array!LExp) ([new LAddr (leftExp)]), 0);
	return llist;
    }
    


}
