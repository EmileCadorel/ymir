module semantic.types.IntUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens;
import lint.LSysCall, std.container, lint.LExp, lint.LConst;
import lint.LCast, lint.LUnop, semantic.types.IntInfo;
import lint.LAddr, lint.LSize;

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

    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, leftExp, op));
	return inst;
    }

    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
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
    
    static LInstList InstUnop (Tokens op) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LUnop (left, op);
	return inst;
    }
    
    static LInstList IntInit (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDWord (0);
	return inst;
    }

    static LInstList IntMax (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDWord (int.max);
	return inst;
    }
    
    static LInstList IntMin (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDWord (int.min);
	return inst;
    }

    static LInstList IntSizeOf (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDWord (IntInfo.sizeOf);
	return inst;
    }    
    
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList ();
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }

    static LInstList InstDXorAff (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXorAff int");
    }

    static LInstList InstDXor (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }
        
}
