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
    static void createCstArray () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.INT);
	auto ofsize = new LReg (LSize.INT);
	Array!LReg args = make!(Array!LReg) (size, ofsize);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp)
				      ([new LBinop (size, new LConstDWord (2, LSize.INT),
						    Tokens.PLUS)]), retReg));
	
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.INT),
				    new LConstDWord (1)));
	
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.INT), LSize.INT), new LBinop (size,
									     ofsize,
									     Tokens.DIV)));

	auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	LFrame.preCompiled [__CstName__] = fr;
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
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.INT);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDWord (1, LSize.INT), LSize.INT),
							      new LRegRead (addr2, new LConstDWord (1, LSize.INT), LSize.INT),
							      Tokens.PLUS),
						  new LConstDWord (1, LSize.INT), Tokens.STAR),
				      new LConstDWord (1, LSize.LONG), Tokens.PLUS);
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.INT), new LConstDWord (1));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.INT), LSize.INT), new LBinop (new LRegRead (addr1, new LConstDWord (1, LSize.INT), LSize.INT),
									    new LRegRead (addr2, new LConstDWord (1, LSize.INT), LSize.INT),
									    Tokens.PLUS));
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr1, new LConstDWord (1, LSize.INT), LSize.INT));
	auto test = new LBinop (index, new LCast (size, LSize.LONG), Tokens.INF);
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (1, LSize.INT), Tokens.STAR), new LConstQWord (2, LSize.INT), Tokens.PLUS),
						Tokens.PLUS), new LConstDWord (0), LSize.INT);
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstQWord (1, LSize.INT), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (2, LSize.INT), Tokens.PLUS)
							 , new LConstDWord (0), LSize.INT));
	vrai1.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai1.insts += new LGoto (debut1);
	entry.insts += vrai1;
	entry.insts += faux1;

	// index2 = 8;
	entry.insts += new LWrite (index2, new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr2, new LConstDWord (1, LSize.INT), LSize.INT));
	
	test = new LBinop (index2, new LCast (size, LSize.LONG), Tokens.INF);
	auto debut2 = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += debut2;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);

	access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (1, LSize.INT), Tokens.STAR), new LConstQWord (2, LSize.INT), Tokens.PLUS),
					   Tokens.PLUS),
			       new LConstDWord (0), LSize.INT);
	
	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstQWord (1, LSize.INT), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (2, LSize.INT), Tokens.PLUS)
							 , new LConstDWord (0), LSize.INT));
	
	vrai2.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai2.insts += new LBinop (index2, new LConstQWord (1), index2, Tokens.PLUS);
	entry.insts += vrai2;
	entry.insts += faux2;
	
	auto fr = new LFrame (__PlusArrayInt__, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusArrayInt__] = fr;
	LReg.lastId = last;
    }

    static void createPlusArrayLong () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.INT);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDWord (1, LSize.INT), LSize.INT),
							      new LRegRead (addr2, new LConstDWord (1, LSize.INT), LSize.INT),
							      Tokens.PLUS),
						  new LConstDWord (1, LSize.INT), Tokens.STAR),
				      new LConstDWord (1, LSize.LONG), Tokens.PLUS);
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.INT), new LConstDWord (1));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.INT), LSize.INT), new LBinop (new LRegRead (addr1, new LConstDWord (1, LSize.INT), LSize.INT),
									    new LRegRead (addr2, new LConstDWord (1, LSize.INT), LSize.INT),
									    Tokens.PLUS));
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr1, new LConstDWord (1, LSize.INT), LSize.INT));
	auto test = new LBinop (index, new LCast (size, LSize.LONG), Tokens.INF);
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (2, LSize.INT), Tokens.STAR), new LConstQWord (2, LSize.INT), Tokens.PLUS),
						Tokens.PLUS),
				    new LConstDWord (0), LSize.LONG);
	
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstQWord (2, LSize.INT), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (2, LSize.INT), Tokens.PLUS)
							 , new LConstDWord (0), LSize.LONG));
	vrai1.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai1.insts += new LGoto (debut1);
	entry.insts += vrai1;
	entry.insts += faux1;

	// index2 = 8;
	entry.insts += new LWrite (index2, new LConstQWord (0));
	entry.insts += new LWrite (size, new LRegRead (addr2, new LConstDWord (1, LSize.INT), LSize.INT));
	
	test = new LBinop (index2, new LCast (size, LSize.LONG), Tokens.INF);
	auto debut2 = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += debut2;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);

	access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (2, LSize.INT), Tokens.STAR),
							       new LConstQWord (2, LSize.INT), Tokens.PLUS), Tokens.PLUS), new LConstDWord (0), LSize.LONG);
	
	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstQWord (4), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (8), Tokens.PLUS)
							 , new LConstDWord (0), LSize.LONG));
	
	vrai2.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai2.insts += new LBinop (index2, new LConstQWord (1), index2, Tokens.PLUS);
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
	inst += new LRegRead (cast (LExp) leftExp, new LConstDWord (1, LSize.INT), LSize.INT);
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
	auto elem = new LBinop (new LConstQWord (8),
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

