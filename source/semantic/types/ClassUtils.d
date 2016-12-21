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
	vrai1.insts += new LWrite (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.LONG),
						 new LConstDWord (0), LSize.INT),
				   new LBinop (new LRegRead (new LRegRead (addr, new LConstDWord (0), LSize.LONG),
							     new LConstDWord (0), LSize.INT), new LConstDWord (1), Tokens.MINUS));
	
	entry.insts += vrai1;
	vrai1.insts += new LJump (test, vrai);
	vrai1.insts += new LGoto (faux);
	
	vrai.insts = new LInstList;
	vrai.insts += new LSysCall ("free", make!(Array!LExp) ([new LRegRead (addr, new LConstDWord (0), LSize.LONG)]));
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


}
