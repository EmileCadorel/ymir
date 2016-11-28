module semantic.types.IntUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens;
import lint.LSysCall, std.container, lint.LExp, lint.LConst;

class IntUtils {

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

    static LInstList InstOpInv (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList ;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (rightExp, leftExp, op));
	return inst;
    }    
    
    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, leftExp, op));
	return inst;
    }

    static LInstList InstOpAffInv (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (rightExp, leftExp, leftExp, op));
	return inst;
    }

    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinopSized (leftExp, rightExp, op, 1));
	return inst;
    }

    static LInstList InstDXorAff (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXorAff int");
    }

    static LInstList InstDXor (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }
        
}
