module semantic.types.CharUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens;
import lint.LExp, lint.LReg, lint.LCast;

class CharUtils {

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
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
	inst += (new LBinop (leftExp, new LCast (rightExp, 1), op));
	return inst;
    }
    
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, 1), rightExp, op));
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
	inst += (new LBinop (leftExp, new LCast (rightExp, 1), leftExp, op));
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
	inst += (new LBinop (new LCast (leftExp, 4), rightExp, op));
	return inst;
    }
    
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, 4), op));
	return inst;
    }

    

}
