module semantic.types.PtrFuncUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LSize;
import ast.Expression, semantic.types.PtrFuncInfo;
import semantic.types.InfoType, lint.LCall;

class PtrFuncUtils {
    
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
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
    
    static LInstList InstConstFunc (InfoType type, Expression, Expression) {
	auto inst = new LInstList;
	auto ptr = cast (PtrFuncInfo) type;
	auto leftExp = new LConstFunc (ptr.score.name);
	inst += leftExp;
	return inst;
    }

    static LInstList InstGetAddr (InfoType, Expression left, Expression right) {
	auto info = left.info;
	auto reg = new LReg (info.id, info.type.size);
	return new LInstList (reg);
    }
    
    static LInstList InstCall (LInstList llist, LInstList rlist) {
	LInstList list = new LInstList;
	auto rightExp = cast (LParam) rlist.getFirst (), leftExp = llist.getFirst ();
	auto call = new LCall (leftExp, rightExp.params, rightExp.size);
	return new LInstList (call);
    }
    
}
