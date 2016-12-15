module semantic.types.ArrayUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LFrame, lint.LCall, lint.LAddr;

class ArrayUtils {

    static immutable string __CstName__ = "_YPCstArray";
    static immutable string __DstName__ = "_YPDstArray";
    static immutable string __AddRef__ = "_YPAddRefArray";
    static immutable string __PlusArrayInt__ = "_YPPlusArrayInt";

    /**
     def AddRef (T)(arr : array!T) {
     if (arr !is null) 
     arr.nbRef++;
     }
    */
    static void createAddRef () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (8);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (addr, 0, 8),
				new LConstQWord (0),
				Tokens.NOT_EQUAL);
	
	auto vrai = new LLabel, faux = new LLabel;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	vrai.insts = new LInstList;
	vrai.insts += new LWrite (new LRegRead (new LRegRead (addr, 0, 8), 0, 4),
				  new LBinop (new LRegRead (new LRegRead (addr, 0, 8),
							    0, 4),
					      new LConstDWord (1), Tokens.PLUS));
	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__AddRef__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__AddRef__] = fr;
	LReg.lastId = last;

    }

    /**
     def DstArray (T) (arr : array!T) {
     if (arr !is null) {
     arr.nbRef --;
     if (arr.nbRef <= 0) free (arr);
     }
     }
    */
    static void createDstArray () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (8);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (addr, 0, 4), new LConstDWord (0),
				Tokens.INF_EQUAL);
	
	auto test1 = new LBinop (addr, new LConstQWord (0), Tokens.NOT_EQUAL);
	auto vrai1 = new LLabel, vrai = new LLabel, faux = new LLabel;

	entry.insts += new LJump (test1, vrai1);
	entry.insts += new LGoto (faux);
	
	vrai1.insts = new LInstList;
	vrai1.insts += new LWrite (new LRegRead (addr, 0, 4), new LBinop (new LRegRead (addr, 0, 4), new LConstDWord (1), Tokens.MINUS));
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
     def cstArray (size : int, ofsize : int) {
     let arr = malloc (size + 9);
     arr.int = 1;
     (arr + 4).int = size / ofsize;
     return arr;
     }
    */
    static void createCstArray () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (4);
	auto ofsize = new LReg (4);
	Array!LReg args = make!(Array!LReg) (size, ofsize);
	auto retReg = new LReg (8);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp)
				      ([new LBinop (size, new LConstDWord (9),
						    Tokens.PLUS)]), retReg));
	
	entry.insts += (new LWrite (new LRegRead (retReg, 0, 4),
				    new LConstDWord (1)));
	
	entry.insts += (new LWrite (new LRegRead (retReg, 4, 4), new LBinop (size,
									     ofsize,
									     Tokens.DIV)));

	LReg.lastId = last;
	auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	LFrame.preCompiled [__CstName__] = fr;

    }

    /**
     def plusArray (a1 : array!int, a2 : array!int) {
        let arr = malloc (a1.size + a2.size + innerSize);
	arr.int = 1;
	(arr + 4).int = a1.size + a2.size;
	arr = cast:array!(T) (arr);
	let i = 0;
	while (i < a1.size) {
	    arr[i] = a1[i];
	    i++;
	}
	let j = 0;
	while (j < a2.size) {
	    arr [i] = a2 [j];
	    j ++;
	    i ++;
	}
	return arr;
     }
     */
    static void createPlusArrayInt () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr1 = new LReg (8), addr2 = new LReg (8), size = new LReg (4);
	auto retReg = new LReg (8);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (8);
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, 4, 4),
							      new LRegRead (addr2, 4, 4),
							      Tokens.PLUS),
						  new LConstDWord (4), Tokens.STAR),
				      new LConstDWord (8), Tokens.PLUS);
	auto index2 = new LReg (8);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, 0, 4), new LConstDWord (1));
	entry.insts += new LWrite (new LRegRead (retReg, 4, 4), new LBinop (new LRegRead (addr1, 4, 4),
									    new LRegRead (addr2, 4, 4),
									    Tokens.PLUS));
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr1, 4, 4));
	auto test = new LBinop (index, new LCast (size, 8), Tokens.INF);
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (4), Tokens.STAR), new LConstQWord (8), Tokens.PLUS), Tokens.PLUS), 0, 4);
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstQWord (4), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (8), Tokens.PLUS)
							 , 0, 4));
	vrai1.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai1.insts += new LGoto (debut1);
	entry.insts += vrai1;
	entry.insts += faux1;

	// index2 = 8;
	entry.insts += new LWrite (index2, new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr2, 4, 4));
	
	test = new LBinop (index2, new LCast (size, 8), Tokens.INF);
	auto debut2 = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += debut2;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);

	access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (4), Tokens.STAR), new LConstQWord (8), Tokens.PLUS), Tokens.PLUS), 0, 4);
	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstQWord (4), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (8), Tokens.PLUS)
							 , 0, 4));
	
	vrai2.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai2.insts += new LBinop (index2, new LConstQWord (1), index2, Tokens.PLUS);
	entry.insts += vrai2;
	entry.insts += faux2;
	LReg.lastId = last;
	
	auto fr = new LFrame (__PlusArrayInt__, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusArrayInt__] = fr;
    }

    
    
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstArray) rightExp) {
	    assert (false, "TODO, a = [...]");
	    //   return affectConstArray (inst, leftExp, cst);
	}

	auto it = (__AddRef__ in LFrame.preCompiled);
	if (it is null) createAddRef ();
	it = (__DstName__ in LFrame.preCompiled);
	if (it is null) createDstArray ();
	inst += new LCall (__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), 0);
	inst += new LCall (__DstName__, make!(Array!LExp) ([leftExp]), 0);
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    static LInstList InstAffectNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	auto it = (__DstName__ in LFrame.preCompiled);
	if (it is null) createDstArray ();
	inst += new LCall (__DstName__, make!(Array!LExp) ([leftExp]), 0);
	inst += new LWrite (leftExp, new LConstQWord (0));
	return inst;
    }

    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (__AddRef__ in LFrame.preCompiled);
	if (it is null) createAddRef ();
	inst += new LCall (__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), 0);
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }
    
    static LInstList InstAffectNullRight (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LWrite (leftExp, new LConstQWord (0));
	return inst;
    }
    

    static LInstList InstDestruct (LInstList llist) {
	auto it = (__DstName__ in LFrame.preCompiled);
	if (it is null) createDstArray ();
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	inst += new LCall (__DstName__, make!(Array!LExp) ([expr]), 0);
	return inst;
    }

    static LInstList InstParam (LInstList llist) {
	auto leftExp = llist.getFirst ();
	auto it = (__AddRef__ in LFrame.preCompiled);
	if (it is null) createAddRef ();
	llist += new LCall (__AddRef__, make!(Array!LExp) ([new LAddr (leftExp)]), 0);
	return llist;
    }

    static LInstList InstLength (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LRegRead (cast (LExp) leftExp, 4, 4);
	return inst;
    }


    static LInstList InstPlus (int size : 4) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__PlusArrayInt__ in LFrame.preCompiled);
	if (it is null) createPlusArrayInt ();
	inst += new LCall (__PlusArrayInt__, make!(Array!LExp) (leftExp, rightExp), 8);
	return inst;
    }
    
    
    static LInstList InstAccessS (int size) (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	if (size > 1) { 
	    auto elem = new LBinop (new LConstQWord (8),
				    new LBinop (leftExp,
						new LBinop (new LCast (rightExp, 8),
							    new LConstQWord (size),
							    Tokens.STAR),
						Tokens.PLUS),
				    Tokens.PLUS);
	    inst += new LRegRead (elem, 0, size);
	} else {
	    auto elem = new LBinop (new LConstQWord (8),
				    new LBinop (leftExp,
						new LCast (rightExp, 8),
						Tokens.PLUS),
				    Tokens.PLUS);
	    inst += new LRegRead (elem, 0, size);
	}

	return inst;
    }
    
    
}

