module semantic.types.ClassUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCall, lint.LFrame, lint.LCast, lint.LAddr;
import std.stdio, lint.LSize, lint.LUnop;


class ClassUtils {

    static immutable string __AddRef__ = "_YPAddRefObj";
    static immutable string __DstName__ = "_YPDstObj";
    
    /**
     def AddRef (elem : object) {
         if (elem !is null)
	    elem.nbRef++;
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
	vrai.insts += new LUnop (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.LONG), new LConstDWord (0), LSize.LONG), Tokens.DPLUS, true);

	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__AddRef__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__AddRef__] = fr;
	LReg.lastId = last;
    }


    /**
     def DstObj (elem : object) {
         if (elem !is null) {
	     elem.nbRef --;
	     if (elem.nbRef <= 0) free (elem);
	 }
     }
     */
    static void createDstObj () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.LONG),
					      new LConstDWord (0), LSize.INT),
				new LConstDWord (0),
				Tokens.INF_EQUAL);

	auto test1 = new LBinop (new LRegRead (addr, new LConstDWord (0), LSize.LONG),
				 new LConstQWord (0), Tokens.NOT_EQUAL);
	
	auto vrai1 = new LLabel, vrai = new LLabel, faux = new LLabel;

	entry.insts += new LJump (test1, vrai1);
	entry.insts += new LGoto (faux);
	
	vrai1.insts = new LInstList;
	vrai1.insts += new LUnop (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.LONG), new LConstDWord (0), LSize.LONG), Tokens.DMINUS, true);
	
	entry.insts += vrai1;
	vrai1.insts += new LJump (test, vrai);
	vrai1.insts += new LGoto (faux);
	
	vrai.insts = new LInstList;
	vrai.insts += new LCall (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.LONG), new LConstDWord (1, LSize.LONG), LSize.LONG),
				 make!(Array!LExp) ([new LRegRead (addr, new LConstDWord (0), LSize.LONG)]),
				 LSize.NONE);
	//vrai.insts += new LSysCall ("free", );
	vrai.insts += new LWrite (new LRegRead (addr, new LConstDWord (0), LSize.LONG), new LConstQWord (0));
	vrai.insts += new LGoto (faux);
	entry.insts += vrai;

	entry.insts += faux;
	auto fr = new LFrame (__DstName__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__DstName__] = fr;
	LReg.lastId = last;
    }

    
    static LInstList InstParam (LInstList llist) {
	auto leftExp = llist.getFirst ();
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) {
	    ClassUtils.createAddRef ();
	}
	llist += new LCall (ClassUtils.__AddRef__, make! (Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	llist += leftExp;
	return llist;
    }
       
    static LInstList InstReturn (LInstList llist) {
	auto leftExp = llist.getFirst ();
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	llist += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	llist += leftExp;
	return llist;
    }
    
    static LInstList InstIs (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.DEQUAL);
	return inst;
    }
    
    static LInstList InstNotIs (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.NOT_EQUAL);
	return inst;
    }

    static LInstList InstIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstQWord (0), Tokens.DEQUAL);
	return inst;
    }
    
    static LInstList InstNotIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstQWord (0), Tokens.NOT_EQUAL);
	return inst;
    }
    
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
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

    
}
