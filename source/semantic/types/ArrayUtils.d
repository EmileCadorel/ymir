module semantic.types.ArrayUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LFrame, lint.LCall, lint.LAddr;
import semantic.types.StringUtils, lint.LSize, lint.LUnop;
import semantic.types.ClassUtils, semantic.types.InfoType;
import ast.Expression, lint.LVisitor, semantic.types.ArrayInfo;
import ast.Constante, syntax.Word;

class ArrayUtils {

    static immutable string __CstName__ = "_YPCstArray";
    static immutable string __CstNameObj__ = "_YPCstArrayObj";
    static immutable string __PlusArrayInt__ = "_YPPlusArrayInt";
    static immutable string __PlusArrayLong__ = "_YPPlusArrayLong";
    static immutable string __DstArray__ = "_YPDstArray";

    /**
     def cstArray (size : int, ofsize : int) {
     let arr = malloc (size + 9);
     arr.int = 1;
     (arr + 4).int = size / ofsize;
     return arr;
     }
    */
    static void createCstArray (string dstName = "free") {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.LONG);
	auto ofsize = new LReg (LSize.LONG);
	Array!LReg args = make!(Array!LReg) (size, ofsize);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp)
				      ([new LBinop (size, new LConstDWord (3, LSize.LONG),
						    Tokens.PLUS)]), retReg));
	
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG),
				    new LConstQWord (1)));
	
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (2, LSize.LONG), LSize.LONG),
				    new LBinop (size,
						ofsize,
						Tokens.DIV)));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG),
				    new LConstFunc (dstName)));

	if (dstName == "free") {
	    auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	    LFrame.preCompiled [__CstName__] = fr;
	} else {
	    auto fr = new LFrame (__CstNameObj__, entry, end, retReg, args);
	    LFrame.preCompiled [__CstNameObj__] = fr;
	}
	LReg.lastId = last;
    }    
    
    /**
     def dstArray (a : array!object) {
        for (i in a) 
	    dstObj (i);
	free (a);
     }
     */
    static void createDstArray () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto size = new LReg (LSize.LONG);
	auto index = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	entry.insts += new LWrite (index, new LConstQWord (0));
	auto test = new LBinop (index, new LRegRead (addr, new LConstDWord (2, LSize.LONG), LSize.LONG), Tokens.INF);
	auto debut = new LLabel, vrai = new LLabel (new LInstList), faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	auto where = new LBinop (addr, new LBinop (new LConstQWord (3, LSize.LONG),
						  new LBinop (index, new LConstQWord (1, LSize.LONG), Tokens.STAR), Tokens.PLUS), Tokens.PLUS);
	vrai.insts += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([where]), LSize.NONE);
	vrai.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai.insts += new LGoto (debut);
	entry.insts += vrai;
	entry.insts += faux;
	entry.insts += new LSysCall ("free", make!(Array!LExp) ([addr]));
	auto fr = new LFrame (__DstArray__, entry, end, null, make!(Array!LReg) (addr));
	LFrame.preCompiled [__DstArray__] = fr;
	LReg.lastId = last;
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
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDWord (2, LSize.LONG), LSize.LONG),
							      new LRegRead (addr2, new LConstDWord (2, LSize.LONG), LSize.LONG),
							      Tokens.PLUS),
						  new LConstDWord (1, LSize.LONG), Tokens.STAR),
				      new LConstQWord (3, LSize.LONG), Tokens.PLUS);
	
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG), new LConstQWord (1));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG),
				    new LConstFunc ("free")));
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (2, LSize.LONG), LSize.LONG),
				   new LBinop (new LRegRead (addr1, new LConstDWord (2, LSize.LONG), LSize.LONG),
					       new LRegRead (addr2, new LConstDWord (2, LSize.LONG), LSize.LONG),
					       Tokens.PLUS));
	
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr1, new LConstDWord (2, LSize.LONG), LSize.LONG)); // size = addr1 [2 * long]
	auto test = new LBinop (index, size, Tokens.INF);
	
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);
	
	// array [3 * long + index * int];
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (1, LSize.INT), Tokens.STAR), new LConstQWord (3, LSize.LONG), Tokens.PLUS),
						Tokens.PLUS), new LConstDWord (0), LSize.INT);
	
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstQWord (1, LSize.INT), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (3, LSize.LONG), Tokens.PLUS),
							 new LConstDWord (0), LSize.INT));
	
	vrai1.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai1.insts += new LGoto (debut1);
	entry.insts += vrai1;
	entry.insts += faux1;

	// index2 = 8;
	entry.insts += new LWrite (index2, new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr2, new LConstDWord (2, LSize.LONG), LSize.LONG)); // size = addr2 [2 * long]
	
	test = new LBinop (index2, size, Tokens.INF);
	auto debut2 = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += debut2;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);

	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstQWord (1, LSize.INT), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (3, LSize.LONG), Tokens.PLUS)
							 , new LConstDWord (0), LSize.INT)); // addr2 [3 * long + index2 * int];
	
	vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai2.insts += new LUnop (index2, Tokens.DPLUS, true);
	entry.insts += vrai2;
	entry.insts += faux2;
	
	auto fr = new LFrame (__PlusArrayInt__, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusArrayInt__] = fr;
	LReg.lastId = last;
    }

    static void createPlusArrayLong () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDWord (2, LSize.LONG), LSize.LONG),
							      new LRegRead (addr2, new LConstDWord (2, LSize.LONG), LSize.LONG),
							      Tokens.PLUS),
						  new LConstDWord (1, LSize.LONG), Tokens.STAR),
				      new LConstDWord (3, LSize.LONG), Tokens.PLUS); // taille = (addr1 [2 * long] + addr2 [2 * long]) * long + 3 * long;
	
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG), new LConstQWord (1));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG),
				    new LRegRead (addr1, new LConstDWord (1, LSize.LONG), LSize.LONG))); // on recupere le destructeur
			
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (2, LSize.LONG), LSize.LONG),
				   new LBinop (new LRegRead (addr1, new LConstDWord (2, LSize.LONG), LSize.LONG),
					       new LRegRead (addr2, new LConstDWord (2, LSize.LONG), LSize.LONG),
					       Tokens.PLUS));
	
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr1, new LConstDWord (2, LSize.LONG), LSize.LONG));
	auto test = new LBinop (index, size, Tokens.INF);
	
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);

	// access = array [3 * long + size * long]
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (1, LSize.LONG), Tokens.STAR),
								    new LConstQWord (3, LSize.LONG), Tokens.PLUS),
						Tokens.PLUS),
				    new LConstDWord (0), LSize.LONG);
	
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstQWord (1, LSize.LONG), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (3, LSize.LONG), Tokens.PLUS)
							 , new LConstDWord (0), LSize.LONG));
	
	vrai1.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai1.insts += new LGoto (debut1);
	entry.insts += vrai1;
	entry.insts += faux1;

	// index2 = 8;
	entry.insts += new LWrite (index2, new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr2, new LConstDWord (2, LSize.LONG), LSize.LONG));
	
	test = new LBinop (index2, size, Tokens.INF);
	auto debut2 = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += debut2;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);
	
	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstQWord (1, LSize.LONG), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (3, LSize.LONG), Tokens.PLUS)
							 , new LConstDWord (0), LSize.LONG));
	
	vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai2.insts += new LUnop (index2, Tokens.DPLUS, true);
	entry.insts += vrai2;
	entry.insts += faux2;
	
	auto fr = new LFrame (__PlusArrayInt__, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusArrayInt__] = fr;
	LReg.lastId = last;
    }

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstArray) rightExp) {
	    assert (false, "TODO, a = [...]");
	    //   return affectConstArray (inst, leftExp, cst);
	}

	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    static LInstList InstAffectNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, new LConstQWord (0));
	return inst;
    }

    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
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
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (expr)]), LSize.NONE);
	return inst;
    }

    static LInstList InstLength (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LRegRead (cast (LExp) leftExp, new LConstDWord (2, LSize.LONG), LSize.LONG);
	return inst;
    }

    static LInstList InstNbRef (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LRegRead (cast (LExp) leftExp, new LConstDWord (0), LSize.LONG);
	return inst;
    }
    

    static LInstList InstPlus (LSize size : LSize.INT) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__PlusArrayInt__ in LFrame.preCompiled);
	if (it is null) createPlusArrayInt ();
	inst += new LCall (__PlusArrayInt__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }

    
    static LInstList InstPlus (LSize size : LSize.LONG) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__PlusArrayLong__ in LFrame.preCompiled);
	if (it is null) createPlusArrayLong ();
	inst += new LCall (__PlusArrayLong__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }

    static LInstList InstPlus (LSize size : LSize.BYTE) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (StringUtils.__PlusString__ in LFrame.preCompiled);
	if (it is null) StringUtils.createPlusString ();
	inst += new LCall (StringUtils.__PlusString__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }

    
    static LInstList InstAccessS (LSize size) (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto elem = new LBinop (new LConstQWord (3, LSize.LONG),
				new LBinop (leftExp,
					    new LBinop (new LCast (rightExp, LSize.LONG),
							new LConstQWord (1, size),
							Tokens.STAR),
					    Tokens.PLUS),
				Tokens.PLUS);
	
	inst += new LRegRead (elem, new LConstDWord (0), size);	
	return inst;
    }
    
    static LInstList InstCastString (LInstList llist) {
	return llist;
    }

    static LInstList ArrayGetType (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	inst += LVisitor.visitExpressionOutSide (left);
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    static LInstList ArrayStringOf (LInstList, LInstList left) {
	return left;
    }
    
    
}

