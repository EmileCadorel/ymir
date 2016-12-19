module semantic.types.StringUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCall, lint.LFrame, lint.LCast, lint.LAddr;
import std.stdio, lint.LSize;

class StringUtils {

    static immutable string __CstName__ = "_YPCstString";
    static immutable string __DstName__ = "_YPDstString";
    static immutable string __AddRef__ = "_YPAddRefString";
    static immutable string __DupString__ = "_YPDupString";
    static immutable string __PlusString__ = "_YPPlusString";
    
    /**
     def AddRef (str : string) {
         if (str !is null)
	    str.nbRef++;
     }
     */
    static void createAddRef () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (addr, new LConstDWord (0), LSize.LONG),
				new LConstQWord (0),
				Tokens.NOT_EQUAL);
	
	auto vrai = new LLabel, faux = new LLabel;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	vrai.insts = new LInstList;
	vrai.insts += new LWrite (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.LONG), new LConstDWord (0), LSize.INT),
				  new LBinop (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.INT),
							    new LConstDWord (0), LSize.INT),
					      new LConstDWord (1), Tokens.PLUS));
	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__AddRef__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__AddRef__] = fr;
	LReg.lastId = last;
    }



    /**
     def DstString (str : string) {
         if (str !is null) {
	     str.nbRef --;
	     if (str.nbRef <= 0) free (str);
	 }
     }
     */
    static void createDstString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (addr, new LConstDWord (0), LSize.INT), new LConstDWord (0), Tokens.INF_EQUAL);
	auto test1 = new LBinop (addr, new LConstQWord (0), Tokens.NOT_EQUAL);
	auto vrai1 = new LLabel, vrai = new LLabel, faux = new LLabel;

	entry.insts += new LJump (test1, vrai1);
	entry.insts += new LGoto (faux);
	
	vrai1.insts = new LInstList;
	vrai1.insts += new LWrite (new LRegRead (addr, new LConstDWord (0), LSize.INT), new LBinop (new LRegRead (addr, new LConstDWord (0), LSize.INT), new LConstDWord (1), Tokens.MINUS));
	entry.insts += vrai1;
	vrai1.insts += new LJump (test, vrai);
	vrai1.insts += new LGoto (faux);
	
	vrai.insts = new LInstList;
	vrai.insts += new LSysCall ("free", make!(Array!LExp) ([addr]));
	vrai.insts += new LGoto (faux);
	entry.insts += vrai;

	entry.insts += faux;
	auto fr = new LFrame (__DstName__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__DstName__] = fr;
	LReg.lastId = last;
    }


    /**
     def cstString (size : int, val : ptr!char) : string {
         str = malloc (size + 8);
	 str.int = 1;
	 (str + 4).int = size;
	 let i = 0;
	 while (*val) {
	     *(str + 8 + i) = *val;
	     i ++;
	     val ++;
	 } 
	 return str;
     }
     */
    static void createCstString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.INT);
	auto addr = new LReg (LSize.LONG);
	Array!LReg args = make!(Array!LReg) (size, addr);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (size, new LConstDWord (2, LSize.INT), Tokens.PLUS)]), retReg));
	auto index = new LReg (LSize.LONG);
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.INT), new LConstDWord (1))); // Une reference, le symbol ""
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.INT), LSize.INT), size));
	entry.insts += (new LWrite (index, new LConstQWord (2, LSize.INT)));
	auto test = new LBinop (new LRegRead (addr, new LConstDWord (0), LSize.BYTE), new LConstByte (0), Tokens.NOT_EQUAL);
	auto debut = new LLabel (), vrai = new LLabel, faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

	vrai.insts = new LInstList;
	auto access = new LRegRead (new LBinop (retReg, index, Tokens.PLUS), new LConstDWord (0), LSize.BYTE);
	vrai.insts += new LWrite (access, new LRegRead (addr, new LConstDWord (0), LSize.BYTE));
	vrai.insts += new LBinop (addr, new LConstQWord (1), addr, Tokens.PLUS);
	vrai.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai.insts += new LGoto (debut);
	
	entry.insts += vrai;
	entry.insts += faux;

	
	LReg.lastId = last;
	auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	LFrame.preCompiled [__CstName__] = fr;
    }

    /**
     def dupString (str:string) {
         let aux = malloc (str.length + 9);
	 aux.int = 1;
	 (aux+4).int = str.length;
	 let i = 0;
	 while (i < str.length) {
	     aux [i] = str [i];
	     i ++;
	 }
	 return aux;
     }
     */
    static void createDupString () {
	assert (false, "TODO dup string");
    }

    static void createPlusString () {
	assert (false, "TODO Plus String");
    }
    
    
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstString (inst, leftExp, cst);

	auto it = (__AddRef__ in LFrame.preCompiled);
	if (it is null) createAddRef ();
	it = (__DstName__ in LFrame.preCompiled);
	if (it is null) createDstString ();
	inst += new LCall (__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LCall (__DstName__, make!(Array!LExp) ([leftExp]), LSize.NONE);

	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    static LInstList InstPlus (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (__PlusString__ in LFrame.preCompiled);
	if (it is null) createPlusString ();
	inst +=  new LCall (__PlusString__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }
    
    static LInstList InstPlusAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (__PlusString__ in LFrame.preCompiled);
	if (it is null) createPlusString ();
	auto res = new LCall (__PlusString__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	auto aux = new LReg (LSize.LONG);
	inst += new LWrite (aux, res);
	it = (__DstName__ in LFrame.preCompiled);
	if (it is null) createDstString ();	
	inst += new LCall (__DstName__, make!(Array!LExp) ([leftExp]), LSize.NONE);
	inst += new LWrite (leftExp, aux);
	inst += new LWrite (new LRegRead (cast (LReg)leftExp, new LConstDWord (0), LSize.INT),
			    new LBinop (new LConstDWord (1), new LRegRead (cast (LReg)leftExp, new LConstDWord (0), LSize.INT), Tokens.PLUS)); // Nb ref
	inst += aux;
	return inst;
    }
    
    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstString (inst, leftExp, cst);
	inst += new LWrite (new LRegRead (cast (LExp)rightExp, new LConstDWord (0), LSize.INT),
			    new LBinop (new LConstDWord (1), new LRegRead (cast (LExp)rightExp, new LConstDWord (0), LSize.INT), Tokens.PLUS)); // Nb ref
	
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

	inst += new LWrite (leftExp, new LCall (__CstName__, exps, LSize.LONG));
	inst += new LWrite (new LRegRead (cast (LExp) leftExp, new LConstDWord (0), LSize.INT),
			    new LBinop (new LConstDWord (1), new LRegRead (cast (LExp) leftExp, new LConstDWord (0), LSize.INT), Tokens.PLUS));
	return inst;
    }
    
    static LInstList InstAccessS (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto elem = new LBinop (new LConstQWord (2, LSize.INT),
			    new LBinop (leftExp, new LCast (rightExp, LSize.LONG),
					Tokens.PLUS),
			    Tokens.PLUS);
	
	inst += new LRegRead (elem, new LConstDWord (0), LSize.BYTE);
	return inst;
    }
    
    static LInstList InstLength (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	if (auto str = (cast(LConstString) leftExp)) {
	    inst += new LConstQWord (str.value.length);
	} else {
	    inst += new LRegRead (cast (LExp) leftExp, new LConstDWord (1, LSize.INT), LSize.INT);
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
	    inst += new LRegRead (cast (LExp) leftExp, new LConstDWord (0), LSize.INT);
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
	inst += new LCall (__DstName__, make!(Array!LExp) ([expr]), LSize.NONE);
	return inst;
    }
    
    static LInstList InstDup (LInstList, LInstList rlist) {
	auto it = (__DupString__ in LFrame.preCompiled);
	if (it is null) {
	    createDupString ();
	}
	auto expr = rlist.getFirst ();
	auto inst = new LInstList;
	inst += rlist;
	inst += new LCall (__DupString__, make!(Array!LExp) ([expr]), LSize.LONG);
	return inst;
    }

    static LInstList InstParam (LInstList llist) {
	auto leftExp = llist.getFirst ();
	auto it = (__AddRef__ in LFrame.preCompiled);
	if (it is null) {
	    createAddRef ();
	}
	llist += new LCall (__AddRef__, make! (Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	llist += leftExp;
	return llist;
    }
       
    static LInstList InstReturn (LInstList llist) {
	auto leftExp = llist.getFirst ();
	auto it = (__AddRef__ in LFrame.preCompiled);
	if (it is null) createAddRef ();
	llist += new LCall (__AddRef__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	llist += leftExp;
	return llist;
    }
    
    static LInstList InstCastArray (LInstList llist) {
	return llist;
    }

    
}
