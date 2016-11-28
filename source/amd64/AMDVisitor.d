module amd64.AMDVisitor;
import target.TVisitor, amd64.AMDReg, target.TInstList;
import amd64.AMDStd, amd64.AMDConst, amd64.AMDLabel;
import amd64.AMDMove, amd64.AMDBinop;
import syntax.Tokens, amd64.AMDSize, amd64.AMDFrame, std.conv;
import amd64.AMDObj, amd64.AMDSysCall, amd64.AMDJumps;
import amd64.AMDCast;

class AMDVisitor : TVisitor {

    override protected TFrame visit (LFrame frame) {
	auto rbp = new AMDReg (REG.getReg ("rbp")), rsp = new AMDReg (REG.getReg ("rsp"));
	AMDReg.lastId = frame.lastId;
	auto stack = new AMDConstQWord (0);
	auto list = new TInstList;
	list += new AMDGlobal (frame.name);
	list += new AMDType (frame.name, AMDTypes.FUNCTION);
	auto label = new AMDLabel (frame.name, new TInstList);
	list += label;
	auto lbl = cast(AMDLabel) visit (frame.entryLbl);
	auto entry = new AMDLabel (lbl.id, new TInstList);
	entry.inst += new AMDCfiStartProc ();
	entry.inst += new AMDPush (rbp);
	entry.inst += new AMDCfiDefCfaOffset (16);
	entry.inst += new AMDCfiOffset (6, 16);
	entry.inst += new AMDMove (rsp, rbp);
	entry.inst += new AMDCfiDefCfaRegister (6);
	entry.inst += new AMDBinop (stack, rsp, Tokens.MINUS);
	foreach (it ; 0 .. frame.args.length) {
	    entry.inst += new AMDMove (new AMDReg (REG.param (it, getSize (frame.args[it].size))),
				       new AMDReg (frame.args[it].id,
						   getSize (frame.args[it].size)));
	}
	entry.inst += lbl.inst;
	entry.inst += visit(frame.returnLbl);
	stack.value = AMDReg.globalOff + (8 - AMDReg.globalOff % 8);
	if (stack.value == 0)
	    entry.inst += new AMDPop (rbp);
	else
	    entry.inst += new AMDLeave ();
	entry.inst += new AMDCfiDefCfa (7, 6);
	entry.inst += new AMDRet;
	entry.inst += new AMDCfiEndProc;
	entry.inst += new AMDInstSize (frame.name);
	label.inst += entry;
	return new AMDFrame (stack, list);
    }

    override protected TLabel visit (LLabel label) {
	auto id = "LBL" ~ to!string (label.id);
	auto lbl = new AMDLabel (id);
	if (label.insts !is null) 
	    lbl.inst = visitInstructions (label.insts);
	else lbl.inst = new TInstList ();
	return lbl;
    }

    override protected TInstList visitJump (LJump lj) {
	auto inst = new TInstList;
	auto exp = visitExpression (lj.test);
	inst += exp.what;
	if ((cast (AMDObj)exp.where).sizeAmd == AMDSize.BYTE) 
	    inst += new AMDBinop (new AMDConstByte (1), cast (AMDObj)exp.where, Tokens.DEQUAL);
	else if ((cast (AMDObj)exp.where).sizeAmd == AMDSize.QWORD) 
	    inst += new AMDBinop (new AMDConstQWord (1), cast (AMDObj)exp.where, Tokens.DEQUAL);
	inst += new AMDJe (lj.id);
	return inst;
    }

    override protected TInstList visitSys (LSysCall lsys) {
	auto inst = new TInstList;
	auto sys = new AMDSysCall (lsys.name);
	foreach (it ; 0 .. lsys.params.length) {
	    auto par = visitExpression (lsys.params [it]);
	    auto reg = new AMDReg (REG.param (it, (cast(AMDObj)par.where).sizeAmd));
	    inst += par.what;
	    inst += new AMDMove (cast(AMDObj)par.where, reg);
	}
	if (lsys.ret !is null) {
	    auto ret = visitExpression (lsys.ret);
	    inst += sys;	
	    auto retReg = new AMDReg (REG.getReg ("rax", (cast(AMDObj)ret.where).sizeAmd));
	    inst += ret.what;
	    inst += new AMDMove (retReg, cast(AMDObj)ret.where);
	}
	inst += sys;
	return inst;
    }

    override protected TInstList visitGoto (LGoto lgoto) {
	return new TInstList (new AMDGoto(lgoto.lbl.id));
    }

    override protected TInstList visitWrite (LWrite write) {
	auto right = visitExpression (write.right);
	auto left = visitExpression (write.left);
	auto inst = new TInstList;
	inst += right.what + left.what;
	auto lreg = (cast (AMDReg) right.where), rreg = (cast(AMDReg) right.where);
	if (lreg !is null && rreg !is null) {
	    if (!lreg.isStd || lreg.isOff || !rreg.isStd || rreg.isOff) {
		auto aux = new AMDReg (REG.getReg ("r10", lreg.sizeAmd));
		inst += new AMDMove (cast (AMDObj)right.where, aux);
		inst += new AMDMove (aux, cast (AMDObj) left.where);
	    } else inst += new AMDMove (cast (AMDObj)right.where, cast (AMDObj) left.where);
	} else {
	    inst += new AMDMove (cast (AMDObj)right.where, cast (AMDObj) left.where);
	}

	return inst;
    }

    override protected TInstPaire visitRegRead (LRegRead lread) {
	auto exp = visitExpression (lread.data);
	auto inst = new TInstList;
	inst += exp.what;
	auto aux = new AMDReg (REG.getReg ("r13", (cast(AMDObj)exp.where).sizeAmd));
	inst += new AMDMove ((cast(AMDObj)exp.where), aux);
	auto fin = new AMDReg (aux.name, aux.sizeAmd);
	fin.isOff = true;
	fin.offset = - cast (long) lread.begin;
	return new TInstPaire (fin, inst);
    }

    override protected TReg visitReg (LReg) {
	assert (false, "TODO");
    }
    
    override protected TInstPaire visitBinop  (LBinop lbin) {
	if (lbin.op == Tokens.DIV) return visitBinopDiv (lbin);
	else if (lbin.op == Tokens.PERCENT) return visitBinopMod (lbin);
	auto inst = new TInstList;
	auto left = visitExpression (lbin.left);
	auto right = visitExpression (lbin.right);
	auto auxr = new AMDReg (REG.getReg ("r11", (cast(AMDObj)right.where).sizeAmd));
	inst += right.what;
	inst += left.what;
	inst += new AMDMove (cast (AMDObj)right.where, auxr);
	auto auxl = new AMDReg (REG.getReg ("r10", (cast(AMDObj)left.where).sizeAmd));
	inst += new AMDMove (cast (AMDObj)left.where, auxl);
	inst += new AMDBinop (auxl, auxr, lbin.op);	    
	if (lbin.res !is null) {	       
	    auto fin = visitExpression (lbin.res);
	    inst += fin.what;
	    inst += new AMDMove (auxr, cast (AMDObj) fin.where);
	    return new TInstPaire (fin.where, inst);
	} else {
	    AMDObj fin = new AMDReg (auxr.sizeAmd);
	    inst += new AMDMove (auxr, fin);
	    return new TInstPaire (fin, inst);
	}
    }

    private TInstPaire visitBinopDiv (LBinop lbin) {
	auto rax = new AMDReg (REG.getReg ("rax"));
	auto inst = new TInstList;
	auto left = visitExpression (lbin.left);
	auto right = visitExpression (lbin.right);
	auto auxr = new AMDReg (REG.getReg ("r11", (cast(AMDObj) right.where).sizeAmd));
	inst += right.what;
	inst += left.what;
	inst += new AMDMove (cast (AMDObj) right.where, auxr);
	inst += new AMDMove (cast (AMDObj) left.where, rax);
	inst += new AMDCqto;
	inst += new AMDUnop (auxr, lbin.op);
	if (lbin.res !is null) {	       
	    auto fin = visitExpression (lbin.res);
	    inst += fin.what;
	    inst += new AMDMove (rax, cast (AMDObj) fin.where);
	    return new TInstPaire (fin.where, inst);
	} else {
	    AMDObj fin = new AMDReg (auxr.sizeAmd);
	    inst += new AMDMove (rax, fin);
	    return new TInstPaire (fin, inst);
	}
    }

    private TInstPaire visitBinopMod (LBinop lbin) {
	auto rax = new AMDReg (REG.getReg ("rax"));
	auto inst = new TInstList;
	auto left = visitExpression (lbin.left);
	auto right = visitExpression (lbin.right);
	auto auxr = new AMDReg (REG.getReg ("r11", (cast(AMDObj) right.where).sizeAmd));
	inst += right.what;
	inst += left.what;
	inst += new AMDMove (cast (AMDObj) right.where, auxr);
	inst += new AMDMove (cast (AMDObj) left.where, rax);
	inst += new AMDCqto;
	inst += new AMDUnop (auxr, Tokens.DIV);
	auto rdx = new AMDReg (REG.getReg ("rdx"));
	if (lbin.res !is null) {	       
	    auto fin = visitExpression (lbin.res);
	    inst += fin.what;
	    inst += new AMDMove (rdx, cast (AMDObj) fin.where);
	    return new TInstPaire (fin.where, inst);
	} else {
	    AMDObj fin = new AMDReg (auxr.sizeAmd);
	    inst += new AMDMove (rdx, fin);
	    return new TInstPaire (fin, inst);
	}	
    }
    
    override protected TInstPaire visitBinopSized (LBinopSized lbin) {
	auto inst = new TInstList;
	auto right = visitExpression (lbin.left);
	auto left = visitExpression (lbin.right);
	auto auxl = new AMDReg (REG.getReg ("r10", (cast(AMDObj)left.where).sizeAmd));
	auto auxr = new AMDReg (REG.getReg ("r11", (cast(AMDObj)right.where).sizeAmd));
	inst += right.what;
	inst += left.what;
	inst += new AMDMove (cast (AMDObj)right.where, auxr);
	inst += new AMDMove (cast (AMDObj)left.where, auxl);
	inst += new AMDBinop (auxl, auxr, Tokens.DEQUAL);	
	auto fin = new AMDReg (getSize (lbin.size));
	inst += new AMDUnop (fin, lbin.op);
	return new TInstPaire (fin, inst);
    }

    override protected TInstPaire visitCall (LCall) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitCast (LCast cst) {
	auto inst = new TInstList;
	auto exp  = visitExpression (cst.what);
	auto aux = new AMDReg (REG.getReg ("r14", (cast(AMDObj)exp.where).sizeAmd));	
	inst += exp.what;
	inst += new AMDMove (cast(AMDObj) exp.where, aux);
	auto res = new AMDReg (REG.getReg ("r14", getSize (cst.size)));
	return new TInstPaire (res, inst);
    }

    override protected TInstPaire visitConstByte (LConstByte val) {
	return new TInstPaire (new AMDConstByte (val.value), new TInstList);
    }

    override protected TInstPaire visitConstWord (LConstWord) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitConstDWord (LConstDWord) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitConstQWord (LConstQWord val) {
	return new TInstPaire (new AMDConstQWord (val.value), new TInstList);
    }

    override protected TInstPaire visitConstFloat (LConstFloat) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitConstDouble (LConstDouble) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitConstString (LConstString lstr) {
	auto str = new AMDConstString (lstr.value);
	return new TInstPaire (str, new TInstList);
    }
    
    override protected TInstPaire visit (LReg reg) {
	return new TInstPaire (new AMDReg (reg.id, getSize (reg.size)), new TInstList);
    }

}
