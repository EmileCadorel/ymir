module semantic.types.StringUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCall, lint.LFrame, lint.LCast, lint.LAddr;
import std.stdio, lint.LSize, lint.LUnop;
import semantic.types.ClassUtils;
import lint.LVisitor, semantic.types.InfoType;
import ast.Expression, ast.Constante, syntax.Word;

class StringUtils {

    static immutable string __CstName__ = "_YPCstString";
    static immutable string __CstNameNoRef__ = "_YPCstStringNoRef";
    static immutable string __DupString__ = "_YPDupString";
    static immutable string __PlusString__ = "_YPPlusString";


    /**
     def cstString (size : long, val : ptr!char) : string {
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
	auto size = new LReg (LSize.LONG);
	auto addr = new LReg (LSize.LONG);
	Array!LReg args = make!(Array!LReg) (size, addr);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (size, new LConstDWord (3, LSize.LONG), Tokens.PLUS)]), retReg));
	auto index = new LReg (LSize.LONG);
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG), new LConstQWord (1))); // Une reference, le symbol ""
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG), new LConstFunc ("free")));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (2, LSize.LONG), LSize.LONG), size));
	
	entry.insts += (new LWrite (index, new LConstQWord (3, LSize.LONG)));
	
	auto test = new LBinop (new LRegRead (addr, new LConstDWord (0), LSize.BYTE), new LConstByte (0), Tokens.NOT_EQUAL);
	auto debut = new LLabel (), vrai = new LLabel, faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

	vrai.insts = new LInstList;
	auto access = new LRegRead (new LBinop (retReg, index, Tokens.PLUS), new LConstDWord (0), LSize.BYTE);
	vrai.insts += new LWrite (access, new LRegRead (addr, new LConstDWord (0), LSize.BYTE));
	vrai.insts += new LUnop (addr, Tokens.DPLUS, true);
	vrai.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai.insts += new LGoto (debut);
	
	entry.insts += vrai;
	entry.insts += faux;

	
	LReg.lastId = last;
	auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	LFrame.preCompiled [__CstName__] = fr;
    }




    /**
     def cstStringNoRef (size : long, val : ptr!char) : string {
         str = malloc (size + 8);
	 str.int = 0;
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
    static void createCstStringNoRef () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.LONG);
	auto addr = new LReg (LSize.LONG);
	Array!LReg args = make!(Array!LReg) (size, addr);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (size, new LConstDWord (3, LSize.LONG), Tokens.PLUS)]), retReg));
	auto index = new LReg (LSize.LONG);
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG), new LConstQWord (0))); // Une reference, le symbol ""
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG), new LConstFunc ("free")));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDWord (2, LSize.LONG), LSize.LONG), size));
	
	entry.insts += (new LWrite (index, new LConstQWord (3, LSize.LONG)));
	
	auto test = new LBinop (new LRegRead (addr, new LConstDWord (0), LSize.BYTE), new LConstByte (0), Tokens.NOT_EQUAL);
	auto debut = new LLabel (), vrai = new LLabel, faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

	vrai.insts = new LInstList;
	auto access = new LRegRead (new LBinop (retReg, index, Tokens.PLUS), new LConstDWord (0), LSize.BYTE);
	vrai.insts += new LWrite (access, new LRegRead (addr, new LConstDWord (0), LSize.BYTE));
	vrai.insts += new LUnop (addr, Tokens.DPLUS, true);
	vrai.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai.insts += new LGoto (debut);
	
	entry.insts += vrai;
	entry.insts += faux;

	
	LReg.lastId = last;
	auto fr = new LFrame (__CstNameNoRef__, entry, end, retReg, args);
	LFrame.preCompiled [__CstNameNoRef__] = fr;
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
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG), retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	
	LExp size = new LBinop (new LRegRead (addr, new LConstDWord (2, LSize.LONG), LSize.LONG),
				new LConstDWord (3, LSize.LONG), Tokens.PLUS);
	
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG), new LConstDWord (1));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG), new LConstFunc ("free"));
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (2, LSize.LONG), LSize.LONG),
				   new LRegRead (addr, new LConstDWord (2, LSize.LONG), LSize.LONG));
    
	entry.insts += new LWrite (index, new LConstQWord (0));
	size = new LRegRead (addr, new LConstDWord (2, LSize.LONG), LSize.LONG);
    
	auto test = new LBinop (index, size, Tokens.INF);
	auto debut = new LLabel, vrai = new LLabel (new LInstList), faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

    auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (1, LSize.BYTE), Tokens.STAR), new LConstQWord (3, LSize.LONG), Tokens.PLUS),
						Tokens.PLUS),
				    new LConstDWord (0), LSize.BYTE);

	vrai.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr, new LBinop (index, new LConstQWord (1, LSize.BYTE), Tokens.STAR),
										Tokens.PLUS),
								    new LConstQWord (3, LSize.LONG), Tokens.PLUS)
							, new LConstDWord (0), LSize.BYTE));
	
	vrai.insts += new LBinop (index, new LConstQWord (1), index, Tokens.PLUS);
	vrai.insts += new LGoto (debut);
	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__DupString__, entry, end, retReg, make!(Array!LReg) (addr));
	LFrame.preCompiled [__DupString__] = fr;
	LReg.lastId = last;
	
    }

    static void createPlusString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDWord (2, LSize.LONG), LSize.LONG),
							      new LRegRead (addr2, new LConstDWord (2, LSize.LONG), LSize.LONG),
							      Tokens.PLUS),
						  new LConstDWord (1, LSize.BYTE), Tokens.STAR),
				      new LConstDWord (3, LSize.LONG), Tokens.PLUS);
	
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG), new LConstDWord (1));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG), new LConstFunc ("free"));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (2, LSize.LONG), LSize.INT),
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
	
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstQWord (1, LSize.BYTE), Tokens.STAR), new LConstQWord (3, LSize.LONG), Tokens.PLUS),
						Tokens.PLUS),
				    new LConstDWord (0), LSize.BYTE);
	
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstQWord (1, LSize.BYTE), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (3, LSize.LONG), Tokens.PLUS)
							 , new LConstDWord (0), LSize.BYTE));
	
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
	
	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstQWord (1, LSize.BYTE), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstQWord (3, LSize.LONG), Tokens.PLUS)
							 , new LConstDWord (0), LSize.BYTE));
	
	vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai2.insts += new LUnop (index2, Tokens.DPLUS, true);
	vrai2.insts += new LGoto (debut2);
	entry.insts += vrai2;
	entry.insts += faux2;
	
	auto fr = new LFrame (__PlusString__, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusString__] = fr;
	LReg.lastId = last;
    }
    
    
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstString (inst, leftExp, cst);

	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);

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
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();	
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
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
	if (auto cst = cast (LConstString) rightExp) return affectConstStringRight (inst, leftExp, cst);
	inst += new LWrite (new LRegRead (cast (LExp)rightExp, new LConstDWord (0), LSize.INT),
			    new LBinop (new LConstDWord (1), new LRegRead (cast (LExp)rightExp, new LConstDWord (0), LSize.INT), Tokens.PLUS)); // Nb ref
	
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }
    
    private static LInstList affectConstStringRight (LInstList inst, LExp leftExp, LConstString rightExp) {	
	Array!LExp exps;
	exps.insertBack (new LConstQWord (rightExp.value.length));
	exps.insertBack (rightExp);
	auto it = (__CstName__ in LFrame.preCompiled);
	if (it is null) {
	    createCstString ();
	}

	inst += new LWrite (leftExp, new LCall (__CstName__, exps, LSize.LONG));
	return inst;
    }

    private static LInstList affectConstString (LInstList inst, LExp leftExp, LConstString rightExp) {	
	Array!LExp exps;
	exps.insertBack (new LConstQWord (rightExp.value.length));
	exps.insertBack (rightExp);
	auto it = (__CstName__ in LFrame.preCompiled);
	if (it is null) createCstString ();
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();

	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp)([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, new LCall (__CstName__, exps, LSize.LONG));
	return inst;
    }
    
    static LInstList InstAccessS (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto elem = new LBinop (new LConstQWord (3, LSize.LONG),
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
	    inst += new LRegRead (cast (LExp) leftExp, new LConstDWord (2, LSize.LONG), LSize.LONG);
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
	    inst += new LRegRead (cast (LExp) leftExp, new LConstDWord (0), LSize.LONG);
	}
	return inst;
    }
    
    static LInstList InstDestruct (LInstList llist) {
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) {
	    ClassUtils.createDstObj ();
	}
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (expr)]), LSize.NONE);
	return inst;
    }
    
    static LInstList InstDup (LInstList, LInstList rlist) {
	auto inst = new LInstList;
	auto rightExp = rlist.getFirst ();
	if (auto cst = cast (LConstString) rightExp) {
	    auto it = (__CstName__ in LFrame.preCompiled);
	    if (it is null) createCstString ();
	    inst += rlist;
	    inst += new LCall (__CstName__, make!(Array!LExp) ([new LConstQWord (cst.value.length), cst]), LSize.LONG);
	    return inst;
	} else {
	    auto it = (__DupString__ in LFrame.preCompiled);
	    if (it is null) createDupString ();	
	    auto expr = rlist.getFirst ();
	    inst += rlist;
	    inst += new LCall (__DupString__, make!(Array!LExp) ([expr]), LSize.LONG);
	    return inst;
	}
    }
    
    static LInstList InstCastArray (LInstList llist) {
	return llist;
    }
    
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList ();
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }

    static LInstList InstComp (LInstList list) {
	auto inst = new LInstList;
	auto rightExp = list.getFirst ();
	if (auto cst = (cast (LConstString) rightExp)) {
	    auto it = (__CstNameNoRef__ in LFrame.preCompiled);
	    if (it is null) createCstStringNoRef ();
	    inst += list;
	    inst += new LCall (__CstNameNoRef__, make!(Array!LExp) ([new LConstQWord (cst.value.length), cst]), LSize.LONG);
	    return inst;
	} else {
	    inst += list;
	    inst += rightExp;
	    return inst;
	}
    }
    
    static LInstList GetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	inst += LVisitor.visitExpressionOutSide (left);
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    static LInstList StringOf (LInstList, LInstList left) {
	return left;
    }


}
