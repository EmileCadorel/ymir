module semantic.types.PtrUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LSize;
import lint.LConst, ast.Constante, syntax.Word;
import lint.LVisitor, semantic.types.InfoType;
import ast.Expression;

class PtrUtils {

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }

    static LInstList InstOp (LSize size, Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new  LBinop (leftExp, new LCast (rightExp, LSize.LONG), op));
	return inst;
    }

    static LInstList InstOpInv (LSize size, Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new  LBinop (new LCast (rightExp, LSize.LONG), leftExp, op));
	return inst;
    }
    
    static LInstList InstUnref (LSize size) (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LRegRead (leftExp, new LConstDWord (0), size);
	return inst;
    }

    static LInstList InstUnrefDot (LSize size) (LInstList, LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LRegRead (leftExp, new LConstDWord (0), size);
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

    static LInstList InstNull (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstQWord (0);
	return inst;
    }
    
    static LInstList InstCast (LInstList llist) {
	return llist;
    }

    static LInstList GetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    static LInstList StringOf (LInstList, LInstList left) {
	return left;
    }


    
}


