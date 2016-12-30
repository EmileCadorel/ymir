module semantic.types.LongUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens;
import lint.LSysCall, std.container, lint.LExp, lint.LConst;
import lint.LCast, lint.LUnop, semantic.types.IntInfo;
import lint.LAddr, lint.LSize, lint.LVisitor;
import syntax.Word, ast.Constante;
import semantic.types.InfoType, semantic.types.LongInfo;

class LongUtils {

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
	inst += (new LWrite (leftExp, new LCast (rightExp, LSize.LONG)));
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
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.LONG), op));
	return inst;
    }
    
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.LONG), rightExp, op));
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
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.LONG), leftExp, op));
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
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.LONG), op));
	return inst;
    }
            
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.LONG), rightExp, op));
	return inst;
    }

    static LInstList InstCastChar (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.BYTE);
	return inst;
    }
    
    static LInstList InstCastBool (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.BYTE);
	return inst;
    }

    static LInstList InstCastInt (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.INT);
	return inst;
    }

    static LInstList InstCastLong (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.LONG);
	return inst;
    }
    
    static LInstList InstUnop (Tokens op) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LUnop (left, op);
	return inst;
    }
    
    static LInstList IntInit (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstQWord (0);
	return inst;
    }

    static LInstList IntMax (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstQWord (long.max);
	return inst;
    }
    
    static LInstList IntMin (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstQWord (long.min);
	return inst;
    }

    static LInstList IntSizeOf (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDWord (1, LongInfo.sizeOf);
	return inst;
    }    
    
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList ();
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }

    static LInstList InstPplus (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LUnop (exp, Tokens.DPLUS, true);
	return inst;
    }

    static LInstList InstSsub (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LUnop (exp, Tokens.DMINUS, true);
	return inst;
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


    static LInstList InstDXorAff (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXorAff long");
    }

    static LInstList InstDXorAffInt (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXorAff long");
    }

    static LInstList InstDXor (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }
    
    static LInstList InstDXorInt (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }
        
    static LInstList InstDXorIntRight (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }

    
}
