module semantic.types.RefUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LSize, semantic.types.ClassUtils;
import semantic.types.ClassUtils, lint.LFrame;
import lint.LCall, lint.LVisitor, semantic.types.InfoType;
import ast.Expression, std.stdio;

class RefUtils {

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }

    static LInstList InstUnrefS (LSize size) (LInstList llist) {
	auto leftExp = llist.getFirst ();
	return new LInstList (new LRegRead (leftExp, new LConstDWord (0), size));
    }    

    
}
