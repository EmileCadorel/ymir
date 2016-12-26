module semantic.types.FloatUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, lint.LExp, lint.LReg, lint.LCast;
import syntax.Tokens, lint.LSize;
import syntax.Word, ast.Constante;
import semantic.types.InfoType, lint.LConst;
import lint.LVisitor;

class FloatUtils {

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }

    
    static LInstList InstAffectInt (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, new LCast (rightExp, LSize.DOUBLE)));
	return inst;
    }

    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }
    
    static LInstList InstOpInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), op));
	return inst;
    }
        
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.DOUBLE), rightExp, op));
	return inst;
    }
    
    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, leftExp, op));
	return inst;
    }

    static LInstList InstOpAffInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), leftExp, op));
	return inst;
    }
    
    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    static LInstList InstOpTestInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), op));
	return inst;
    }
    
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.DOUBLE), rightExp, op));
	return inst;
    }

    static LInstList InstCastInt (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LCast (leftExp, LSize.INT);
	return inst;
    }

    static LInstList InstCastLong (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LCast (leftExp, LSize.LONG);
	return inst;
    }
    
    static LInstList FloatInit (LInstList, LInstList) {
	return new LInstList (new LConstFloat (0.0f));
    }
    
    static LInstList Max (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.max));
    }

    static LInstList Min (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.min_normal));
    }
    
    static LInstList Nan (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.nan));
    }

    static LInstList Dig (LInstList, LInstList) {
	return new LInstList (new LConstDWord (float.dig));
    }
    
    static LInstList Epsilon (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.epsilon));
    }

    static LInstList MantDig (LInstList, LInstList) {
	return new LInstList (new LConstDWord (float.mant_dig));
    }

    static LInstList Max10Exp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.max_10_exp));
    }

    static LInstList MaxExp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.max_exp));
    }
    
    static LInstList Min10Exp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.min_10_exp));
    }

    static LInstList MinExp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.min_exp));
    }

    static LInstList Inf (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.infinity));
    }

    static LInstList FloatGetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    static LInstList FloatStringOf (LInstList, LInstList left) {
	return left;
    }

    
}
