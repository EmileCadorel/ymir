module semantic.types.PtrUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast;

class PtrUtils {

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }

    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new  LBinop (leftExp, new LCast (rightExp, 8), op));
	return inst;
    }

    static LInstList InstOpInv (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new  LBinop (new LCast (rightExp, 8), leftExp, op));
	return inst;
    }
    
    static LInstList InstUnref (int size) (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LRegRead (leftExp, 0, size);
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

    
}
