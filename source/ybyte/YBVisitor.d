module ybyte.YBVisitor;
public import target.TVisitor;
import ybyte.YBBinop, ybyte.YBCall, ybyte.YBConst;
import ybyte.YBFrame, ybyte.YBGoto, ybyte.YBJump;
import ybyte.YBLabel, ybyte.YBParams, ybyte.YBReg;
import ybyte.YBRegRead, ybyte.YBRet, ybyte.YBSize;
import ybyte.YBSysCall, ybyte.YBWrite, ybyte.YBCast;
import std.container;


class YBVisitor : TVisitor {
    
    override protected TFrame visit (LFrame frame) {
	auto retour = new YBFrame (frame.number, frame.name);
	TReg.lastId = frame.lastId;
	retour.entryLbl = visit (frame.entryLbl);
	retour.returnLbl = visit (frame.returnLbl);
	foreach (it ; frame.args) {
	    retour.paramRegs.insertBack (visitReg (it));
	}	
	retour.returnReg = visitReg (frame.returnReg);
	(cast(YBLabel)retour.returnLbl).insts += new YBRet (retour.returnReg);
	
	return retour;
    }
       
    override protected TLabel visit (LLabel label) {
	auto lbl = new YBLabel (label.id);
	lbl.insts = visitInstructions (label.insts);
	return lbl;
    }

    override protected TInstList visitJump (LJump jump) {
	auto texp = visitExpression (jump.test);
	auto inst = new TInstList ;
	inst += texp.what;
	inst += new YBJump (texp.where, jump.id);
	return inst;
    }

    
    override protected TInstList visitSys (LSysCall sys) {
	Array!TExp params;
	auto list = new TInstList;
	foreach (it ; sys.params) {
	    auto instPaire = visitExpression (it);
	    list += instPaire.what;
	    params.insertBack (instPaire.where);
	}
	if (sys.ret is null)
	    list += new YBSysCall (sys.name, params);
	else {
	    auto paire = visitExpression (sys.ret);
	    list += paire.what;
	    list += new YBSysCall (sys.name, params, paire.where);
	}

	return list;
    }
        
    override protected TInstList visitGoto (LGoto elem) {
	auto go = new YBGoto (elem.lbl.id);
	auto inst = new TInstList;
	inst += go;
	return inst;
    }
    
    override protected TInstList visitWrite (LWrite write) {
	auto right = visitExpression (write.right);
	auto left = visitExpression (write.left);
	auto fin = new TInstList ();
	fin += (right.what + left.what);
	fin += (new YBWrite (right.where, left.where));
	return fin;
    }

    override protected TInstPaire visitRegRead (LRegRead reg) {
	auto inst = new TInstList;
	auto paire = visitExpression (reg.data);
	inst += paire.what;
	return new TInstPaire (new YBRegRead (paire.where, reg.begin, reg.size), inst);
    }

    override protected TReg visitReg (LReg reg) {
	if (reg !is null) return new YBReg (reg.id, reg.size);
	else return null;
    }
    
    override protected TInstPaire visitBinop (LBinop bin) {
	auto op = bin.op;
	auto right = visitExpression (bin.right);
	auto left = visitExpression (bin.left);
	if (bin.res !is null) {
	    auto res = visitExpression (bin.res);
	    auto inst = new TInstList;
	    inst += right.what + left.what + res.what;
	    inst += new YBBinop (op, left.where, right.where, res.where);
	    return new TInstPaire (res.where, inst);
	} else {
	    auto aux = (new YBReg (TReg.lastId, left.where.size));
	    auto inst = new TInstList;
	    inst += right.what + left.what;
	    inst += new YBBinop (op, left.where, right.where, aux);
	    return new TInstPaire (aux, inst);
	}
    }
    
    override protected TInstPaire visitBinopSized (LBinopSized bin) {
	auto op = bin.op;
	auto right = visitExpression (bin.right);
	auto left = visitExpression (bin.left);
	auto res = new YBReg (TReg.lastId, bin.size);
	auto inst = new TInstList;
	inst += right.what + left.what;
	inst += new YBBinop (op, left.where, right.where, res);
	return new TInstPaire (res, inst);
    }
    
    override protected TInstPaire visitCall (LCall call) {
	auto list = new TInstList;
	foreach (it ; call.params) {
	    auto instPaire = visitExpression (it);
	    list += instPaire.what;
	    list += new YBParams (instPaire.where);
	}
	list += new YBCall (call.name);
	return new TInstPaire (new YBReg (0, 8), list);
    }

    override protected TInstPaire visitCast (LCast _cast) {
	auto list = new TInstList;
	auto aux = new YBReg (LReg.lastId, _cast.size);
	auto rlist = visitExpression (_cast.what);
	list += rlist.what;
	list += new YBCast (rlist.where, aux);
	return new TInstPaire (aux, list);	
    }
    
    override protected TInstPaire visitConstByte (LConstByte by) {
	return new TInstPaire (new YBConstByte (by.value), new TInstList);
    }

    override protected TInstPaire visitConstWord (LConstWord w) {
	return new TInstPaire (new YBConstWord (w.value), new TInstList);
    }

    override protected TInstPaire visitConstDWord (LConstDWord dw) {
	return new TInstPaire (new YBConstDWord (dw.value), new TInstList);
    }

    override protected TInstPaire visitConstQWord (LConstQWord qw) {
	return new TInstPaire (new YBConstQWord (qw.value), new TInstList);
    }

    override protected TInstPaire visitConstFloat (LConstFloat lf) {
	return new TInstPaire (new YBConstFloat (lf.value), new TInstList);
    }

    override protected TInstPaire visitConstDouble (LConstDouble ld) {
	return new TInstPaire (new YBConstDouble (ld.value), new TInstList);
    }
    
    override protected TInstPaire visit (LReg reg) {
	if (reg !is null) {
	    return new TInstPaire (new YBReg (reg.id, reg.size), new TInstList);
	} else return null;
    }
}
