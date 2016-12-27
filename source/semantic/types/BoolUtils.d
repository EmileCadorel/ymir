module semantic.types.BoolUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens, lint.LCast;
import semantic.types.IntInfo, lint.LUnop, lint.LAddr;
import lint.LConst, lint.LSize;
import ast.Constante, lint.LVisitor, syntax.Word;
import semantic.types.InfoType, ast.Var;

class BoolUtils {

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    static LInstList InstUnop (Tokens op) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LUnop (left, op);
	return inst;
    }

    static LInstList InstXor (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LBinop (left, new LConstByte (1), Tokens.XOR);
	return inst;
    }
    
    static LInstList InstCastChar (LInstList llist) {
	return llist;
    }

    static LInstList InstCastInt (LInstList llist) {
	auto list = new LInstList;
	auto first = llist.getFirst ();
	list += llist;
	list += new LCast (first, LSize.INT);
	return list;
    }

    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }

    static LInstList BoolInit (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstByte (0);
	return inst;
    }

    static LInstList BoolSize (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstDWord (1, LSize.BYTE);
	return inst;
    }
    
    static LInstList BoolGetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    static LInstList BoolStringOf (LInstList, LInstList left) {
	return left;
    }
           
    static LInstList InstTrue (LInstList, LInstList) {
	return new LInstList (new LConstByte (1));
    }

    static LInstList InstFalse (LInstList, LInstList) {
	return new LInstList (new LConstByte (0));
    }

}
