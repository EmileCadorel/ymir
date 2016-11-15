module target.TVisitor;
import lint.LFrame, target.TFrame, target.TLabel, lint.LLabel;
import lint.LReg, target.TReg, target.TInstList, lint.LInstList;
import lint.LInst, lint.LWrite, target.TInstPaire, lint.LExp, target.TWrite;
import lint.LRegRead, target.TRegRead, lint.LData, lint.LConst;
import target.TConst, lint.LBinop, target.TBinop, lint.LGoto, target.TGoto;
import lint.LSysCall, target.TSysCall, target.TExp, lint.LJump, target.TJump;
import target.TRet;
import std.container;

class TVisitor {

    Array!TFrame visit (Array!LFrame frames) {
	Array!TFrame ret;
	foreach (it ; frames) {
	    ret.insertBack (this.visit (it));
	}
	return ret;
    }
    
    private TFrame visit (LFrame frame) {
	TFrame retour = new TFrame (frame.number, frame.name);
	retour.entryLbl = visit (frame.entryLbl);
	retour.returnLbl = visit (frame.returnLbl);
	foreach (it ; frame.args) {
	    retour.paramRegs.insertBack (visitReg (it));
	}	
	retour.returnReg = visitReg (frame.returnReg);
	retour.returnLbl.insts += new TRet (retour.returnReg);
	
	return retour;
    }
       
    private TLabel visit (LLabel label) {
	auto lbl = new TLabel (label.id);
	lbl.insts = visitInstructions (label.insts);
	return lbl;
    }

    private TInstList visitInstructions (LInstList inst) {
	if (inst is null) return new TInstList;
	auto ret = new TInstList;
	foreach (it ; inst.insts) {
	    ret += visit (it);
	}
	return ret;
    }

    private TInstList visit (LInst inst) {
	if (auto write = cast (LWrite) (inst)) return visitWrite (write);
	else if (auto bin = cast (LBinop) (inst)) return visitBinop (bin).what;
	else if (auto go = cast (LGoto) (inst)) return visitGoto (go);
	else if (auto sys = cast (LSysCall) inst) return visitSys (sys);
	else if (auto jump = cast (LJump) inst) return visitJump (jump);
	else if (auto lbl = cast (LLabel) inst) return new TInstList (visit (lbl));
	assert (false, "TODO, visit (" ~ inst.toString () ~ ")");
    }

    private TInstList visitJump (LJump jump) {
	auto texp = visitExpression (jump.test);
	auto inst = new TInstList ;
	inst += texp.what;
	inst += new TJump (texp.where, jump.id);
	return inst;
    }

    
    private TInstList visitSys (LSysCall sys) {
	Array!TExp params;
	auto list = new TInstList;
	foreach (it ; sys.params) {
	    auto instPaire = visitExpression (it);
	    list += instPaire.what;
	    params.insertBack (instPaire.where);
	}
	list += new TSysCall (sys.name, params);
	return list;
    }
    
    private TInstList visitGoto (LGoto elem) {
	auto go = new TGoto (elem.lbl.id);
	auto inst = new TInstList;
	inst += go;
	return inst;
    }
    
    private TInstList visitWrite (LWrite write) {
	auto right = visitExpression (write.right);
	auto left = visitExpression (write.left);
	auto fin = new TInstList ();
	fin += (right.what + left.what);
	fin += (new TWrite (right.where, left.where));
	return fin;
    }

    private TInstPaire visitExpression (LExp elem) {
	if (auto reg = cast(LRegRead) elem) return visitRegRead (reg);
	else if (auto reg = cast(LReg) elem) return visit (reg);
	else if (auto co = cast (LConst) elem) return visitConst (co);
	else if (auto bin = cast(LBinopSized) elem) return visitBinopSized (bin);
	else if (auto bin = cast (LBinop) elem) return visitBinop (bin);
	assert (false, "TODO, visitExpression (LExp)");
    }

    private TInstPaire visitRegRead (LRegRead reg) {
	return new TInstPaire (new TRegRead (visitReg (reg.data), reg.begin, reg.size), new TInstList);
    }

    private TReg visitReg (LReg reg) {
	if (reg !is null) return new TReg (reg.id, reg.size);
	else return null;
    }
    
    private TInstPaire visitBinop (LBinop bin) {
	auto op = bin.op;
	auto right = visitExpression (bin.right);
	auto left = visitExpression (bin.left);
	if (bin.res !is null) {
	    auto res = visitExpression (bin.res);
	    auto inst = new TInstList;
	    inst += right.what + left.what + res.what;
	    inst += new TBinop (op, left.where, right.where, res.where);
	    return new TInstPaire (res.where, inst);
	} else {
	    auto aux = (new TReg (LReg.lastId, left.where.size));
	    auto inst = new TInstList;
	    inst += right.what + left.what;
	    inst += new TBinop (op, left.where, right.where, aux);
	    return new TInstPaire (aux, inst);
	}
    }
    
    private TInstPaire visitBinopSized (LBinopSized bin) {
	auto op = bin.op;
	auto right = visitExpression (bin.right);
	auto left = visitExpression (bin.left);
	auto res = new TReg (LReg.lastId, bin.size);
	auto inst = new TInstList;
	inst += right.what + left.what;
	inst += new TBinop (op, left.where, right.where, res);
	return new TInstPaire (res, inst);
    }
			       
    private TInstPaire visitConst (LConst co) {
	if (auto by = cast(LConstByte) (co))
	    return new TInstPaire (new TConstByte (by.value), new TInstList);
	else if (auto dw = cast(LConstDWord) (co))
	    return new TInstPaire (new TConstDWord (dw.value), new TInstList);
	else if (auto qw = cast(LConstQWord) (co))
	    return new TInstPaire (new TConstQWord (qw.value), new TInstList);
	else if (auto lf = cast(LConstFloat) (co))
	    return new TInstPaire (new TConstFloat (lf.value), new TInstList);
	else if (auto ld = cast(LConstDouble) (co))
	    return new TInstPaire (new TConstDouble (ld.value), new TInstList);
	assert (false, "TODO, visitConst (LConst co)");
    }

    private TInstPaire visit (LReg reg) {
	if (reg !is null) {
	    return new TInstPaire (new TReg (reg.id, reg.size), new TInstList);
	} else return null;
    }
    
    
}
