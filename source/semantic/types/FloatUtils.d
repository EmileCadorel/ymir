module semantic.types.FloatUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, lint.LExp, lint.LReg, lint.LCast;
import syntax.Tokens;

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
	inst += (new LWrite (leftExp, new LCast (rightExp, -8)));
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
	inst += (new LBinop (leftExp, new LCast (rightExp, -8), op));
	return inst;
    }
        
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, -8), rightExp, op));
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
	inst += (new LBinop (leftExp, new LCast (rightExp, -8), leftExp, op));
	return inst;
    }
    
    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinopSized (leftExp, rightExp, op, 1));
	return inst;
    }

    static LInstList InstOpTestInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinopSized (leftExp, new LCast (rightExp, -8), op, 1));
	return inst;
    }
    
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinopSized (new LCast (leftExp, -8), rightExp, op, 1));
	return inst;
    }


    
    
    
}
