module semantic.types.RangeUtils;
import lint.LSize, lint.LInstList, lint.LWrite;
import lint.LConst, lint.LRegRead;
import semantic.types.ClassUtils, lint.LBinop;
import syntax.Tokens, lint.LCall, lint.LFrame;
import std.container, lint.LExp, lint.LAddr;
import lint.LReg, lint.LLabel, lint.LSysCall;
import semantic.types.InfoType, ast.Expression;
import std.container, semantic.types.RangeInfo;
import lint.LVisitor, lint.LGoto, lint.LJump;
import lint.LUnop, ast.ParamList;
import lint.LCast;

class RangeUtils {

    static string __CstName__ = "_YPCstRange";

    static void createCstRange () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (new LConstQWord (2, LSize.LONG),
									     new LBinop (size, new LConstQWord (2), Tokens.STAR),
									     Tokens.PLUS)]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG), new LConstQWord (1));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG), new LConstFunc ("free"));
	auto fr = new LFrame (__CstName__, entry, end, retReg, make!(Array!LReg) ([size]));
	LFrame.preCompiled [__CstName__] = fr;
	LReg.lastId = last;
    }
    
    static LInstList InstFst (LSize size) (LInstList, LInstList llist) {
	auto leftExp = llist.getFirst ();
	llist += new LRegRead (leftExp, new LConstDWord (2, LSize.LONG), size);
	return llist;
    }
    
    static LInstList InstScd (LSize size) (LInstList, LInstList llist) {
	auto leftExp = llist.getFirst ();
	llist += new LRegRead (leftExp, new LBinop (new LConstDWord (2, LSize.LONG),
						    new LConstDWord (1, size),
						    Tokens.PLUS),
			       size);
	return llist;
    }

    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LWrite (leftExp, rightExp);
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


    static LInstList InstIn (LSize size) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto scd = new LRegRead (rightExp, new LBinop (new LConstDWord (2, LSize.LONG),
						      new LConstDWord (1, size),
						      Tokens.PLUS),
				 size);
	auto fst = new LRegRead (rightExp, new LConstDWord (2, LSize.LONG), size);
	inst += new LBinop (new LBinop (leftExp, fst, Tokens.SUP_EQUAL), new LBinop (leftExp, scd, Tokens.INF_EQUAL), Tokens.DAND);
	return inst;
    }

    
    static LInstList InstApplyPreTreat (InfoType _type, Expression _left, Expression _right) {
	auto inst = new LInstList;
	auto type = cast (RangeInfo) _type;
	auto left = LVisitor.visitExpressionOutSide (_left);
	auto right = LVisitor.visitExpressionOutSide ((cast (ParamList) _right).params [0]);
	auto leftExp = left.getFirst (), rightExp = right.getFirst ();
	inst += left + right;
	auto debut = new LLabel, vrai = new LLabel (new LInstList), block = new LLabel ("tmp_block");
	auto faux = new LLabel;
	auto index = new LReg (type.content.size);
	auto fst = new LRegRead (leftExp, new LConstDWord (2, LSize.LONG), type.content.size);
	inst += new LWrite (index, fst);
	auto scd = new LRegRead (leftExp, new LBinop (new LConstQWord (2, LSize.LONG),
						  new LConstQWord (1, type.content.size),
						  Tokens.PLUS), type.content.size);
	    
	auto test = new LBinop (index,  scd, Tokens.NOT_EQUAL);
	inst += debut;
	inst += new LJump (test, vrai);
	inst += new LGoto (faux);
	vrai.insts += new LWrite (rightExp, index);
	vrai.insts += block;
	auto vrai2 = new LLabel (new LInstList), faux2 = new LLabel (new LInstList);
	vrai.insts += new LJump (new LBinop (fst, scd, Tokens.INF), vrai2);
	vrai.insts += new LGoto (faux2);
	if (type.content.size == LSize.FLOAT || type.content.size == LSize.DOUBLE) {
	    vrai2.insts += new LBinop (index, new LCast (new LConstDouble (1), type.content.size), index, Tokens.PLUS);
	    vrai2.insts += new LGoto (debut);
	    faux2.insts += new LBinop (index, new LCast (new LConstDouble (1.), type.content.size), index, Tokens.MINUS);
	    faux2.insts += new LGoto (debut);
	} else {
	    vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	    vrai2.insts += new LGoto (debut);
	    faux2.insts += new LUnop (index, Tokens.DMINUS, true);
	    faux2.insts += new LGoto (debut);
	}
	vrai.insts += vrai2;
	vrai.insts += faux2;
	inst += vrai;
	inst += faux;
	return inst;
    }

    static LInstList InstApply (LInstList func, LInstList block) {
	return func.replace ("tmp_block", block);
    }


    
}
