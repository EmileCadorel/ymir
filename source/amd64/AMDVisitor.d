module amd64.AMDVisitor;
import target.TVisitor, amd64.AMDReg, target.TInstList;
import amd64.AMDStd, amd64.AMDConst, amd64.AMDLabel;
import amd64.AMDMove, amd64.AMDBinop;
import syntax.Tokens, amd64.AMDSize, amd64.AMDFrame, std.conv;
import amd64.AMDObj, amd64.AMDSysCall, amd64.AMDJumps;
import amd64.AMDCast, amd64.AMDCall, amd64.AMDUnop, amd64.AMDLeaq;
import std.math, amd64.AMDLocus, amd64.AMDCvtt;
import std.stdio, lint.LSize, utils.exception;


class AMDVisitor : TVisitor {

    private int max (int a, int b) {
	return (abs (a) > abs (b)) ? a : b;
    }
    
    override protected TFrame visit (LFrame frame) {
	AMDReg.resetOff ();
	auto file =  new AMDFile (frame.file);
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
	entry.inst += file;
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
	if (frame.returnReg !is null) {
	    auto ret = new AMDReg (REG.getReg ("rax", getSize (frame.returnReg.size)));
	    auto left = visitExpression (frame.returnReg, ret);
	    entry.inst += left.what;
	    if (left.where != ret)
		entry.inst += new AMDMove (cast (AMDObj)left.where, ret);
	}
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
	if (cast (AMDReg) exp.where) {
	    auto reg = (cast (AMDReg) exp.where).clone (AMDSize.BYTE);
	    inst += new AMDBinop (new AMDConstByte (0), reg, Tokens.DEQUAL);
	} else {
	    auto reg = new AMDReg (REG.aux (AMDSize.BYTE));
	    inst += new AMDMove (cast (AMDObj) exp.where, reg);
	    inst += new AMDBinop (new AMDConstByte (0), reg, Tokens.DEQUAL);
	}
	inst += new AMDJne (lj.id);
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
	} else inst += sys;
	return inst;
    }

    override protected TInstList visitGoto (LGoto lgoto) {
	return new TInstList (new AMDGoto(lgoto.lbl.id));
    }

    override protected TInstList visitWrite (LWrite write) {
	if (cast (LRegRead) write.left) return visitWriteRegRead (write);
	auto left = visitExpression (write.left);
	auto right = visitExpression (write.right, left.where);
	auto inst = new TInstList;
	if (right.where != left.where) {
	    inst += right.what;	    
	    auto lreg = (cast (AMDReg) right.where), rreg = (cast(AMDReg) right.where);	    
	    if (lreg !is null && rreg !is null) {
		if (!lreg.isStd || lreg.isOff || !rreg.isStd || rreg.isOff) {
		    auto aux = new AMDReg (REG.getSwap (lreg.sizeAmd));
		    inst += new AMDMove (cast (AMDObj)right.where, aux);
		    inst += left.what;
		    inst += new AMDMove (aux, cast (AMDObj) left.where);
		} else {
		    inst += left.what;
		    inst += new AMDMove (cast (AMDObj)right.where, cast (AMDObj) left.where);
		}
	    } else {
		inst += left.what;
		inst += new AMDMove (cast (AMDObj)right.where, cast (AMDObj) left.where);
	    }
	} else {
	    inst += left.what + right.what;
	}
	return inst;
    }

    override TInstList visitLocus (LLocus locus) {
	return new TInstList (new AMDLocus (locus.locus));
    }
    
    private TInstList visitWriteRegRead (LWrite write) {
	auto inst = new TInstList;
	auto left = visitExpression (write.left);
	auto right = visitExpression (write.right);
	auto rreg = cast (AMDObj) right.where;
	inst += right.what;
	if (cast (AMDConst) rreg is null) {
	    auto aux = new AMDReg (REG.getSwap (rreg.sizeAmd));
	    inst += new AMDMove (cast (AMDObj) right.where, aux);
	    inst += left.what;
	    inst += new AMDMove (aux, cast (AMDObj) left.where);
	    REG.free (aux);
	} else {
	    inst += left.what;
	    inst += new AMDMove (rreg, cast (AMDObj) left.where);
	}
	
	return inst;
    }
    
    override protected TInstPaire visitRegRead (LRegRead lread) {
	auto exp = visitExpression (lread.data);
	auto inst = new TInstList;
	inst += exp.what;
	auto aux = new AMDReg (REG.getReg ("rax", (cast(AMDObj)exp.where).sizeAmd));
	inst += new AMDMove ((cast(AMDObj)exp.where), aux);
	auto fin = new AMDReg (aux.name, aux.sizeAmd);
	fin.isOff = true;
	auto res = this.resolve!AMDConstDWord (lread.begin);
	if (res is null) assert (false, "TODO");
	fin.offset = -res.value;
	fin.resize (getSize (lread.size));
	return new TInstPaire (fin, inst);
    }

    override protected TInstPaire visitRegRead (LRegRead lread, TExp) {
	auto exp = visitExpression (lread.data);
	auto inst = new TInstList;
	inst += exp.what;
	auto aux = new AMDReg (REG.getReg ("rax", (cast(AMDObj)exp.where).sizeAmd));
	inst += new AMDMove ((cast(AMDObj)exp.where), aux);
	auto fin = new AMDReg (aux.name, aux.sizeAmd);
	fin.isOff = true;
	auto res = this.resolve!(AMDConst) (lread.begin);
	if (auto _res = cast (AMDConstDWord) (res))
	    fin.offset = -_res.value;
	else if (auto _res = cast (AMDConstQWord) (res))
	    fin.offset = -_res.value;      
	else  assert (false, "TODO");
	fin.resize (getSize (lread.size));
	return new TInstPaire (fin, inst);
    }

    
    override protected TReg visitReg (LReg) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitBinop (LBinop lbin) {
	auto res = resolve!(AMDObj) (lbin);
	if (res !is null) return new TInstPaire (res, new TInstList);
	auto size = getSize (lbin.left.size);
	TInstPaire ret;
	auto where = new AMDReg (REG.aux (size));
	if (size == AMDSize.BYTE) ret = visitBinopByte (lbin, where);
	else if (size == AMDSize.WORD) ret = visitBinopWord (lbin, where);
	else if (size == AMDSize.DWORD) ret = visitBinopDWord (lbin, where);
	else if (size == AMDSize.QWORD) ret = visitBinopQWord (lbin, where);
	else if (size == AMDSize.SPREC) ret = visitBinopSPrec (lbin, where);
	else if (size == AMDSize.DPREC) ret = visitBinopDPrec (lbin, where);
	else assert (false, "TODO");
	REG.freeAll ();
	return ret;
    }
    
    override protected TInstPaire visitBinop  (LBinop lbin, TExp where) {
	auto res = resolve!(AMDObj) (lbin);
	if (res !is null) return new TInstPaire (res, new TInstList);
	auto size = getSize (lbin.left.size);
	if (size == AMDSize.BYTE) return visitBinopByte (lbin, where);
	else if (size == AMDSize.WORD) return visitBinopWord (lbin, where);
	else if (size == AMDSize.DWORD) return visitBinopDWord (lbin, where);
	else if (size == AMDSize.QWORD) return visitBinopQWord (lbin, where);
	else if (size == AMDSize.SPREC) return visitBinopSPrec (lbin, where);
	else if (size == AMDSize.DPREC) return visitBinopDPrec (lbin, where);
	else assert (false, "TODO");
    }

    private TInstPaire visitBinopByte (LBinop lbin, TExp twhere) {
	auto ret = new TInstList;
	bool free = false;
	AMDReg where;
	if (lbin.res is null)
	    where = cast (AMDReg) twhere;
	else {
	    auto wh = visitExpression (lbin.res);
	    ret += wh.what;
	    where = cast (AMDReg) wh.where;
	}
	
	where.resize (AMDSize.BYTE);
	auto laux = new AMDReg (REG.aux (AMDSize.BYTE));
	auto lpaire = visitExpression (lbin.left, laux);
	if (laux != lpaire.where) {
	    free = true;
	    REG.free (laux);
	}
	
	auto rpaire = visitExpression (lbin.right, where);	
	ret += rpaire.what;
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    ret += new AMDMove (cast (AMDObj) rpaire.where, where);       
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, where, lbin.op);
	} else {
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	}
	if (!free) REG.free (laux);
	return new TInstPaire (where, ret);
    }

    private TInstPaire visitBinopWord (LBinop lbin, TExp where) {
	assert (false, "TODO");
    }

    private TInstPaire visitBinopDWord (LBinop lbin, TExp twhere) {
	auto ret = new TInstList;
	bool free = false;
	AMDReg where;
	if (lbin.res is null) {
	    where = cast (AMDReg) twhere;
	} else {
	    auto wh = visitExpression (lbin.res);
	    ret += wh.what;
	    where = cast (AMDReg) wh.where;
	}
	auto laux = new AMDReg (REG.aux (AMDSize.DWORD));
	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    REG.reserve (where);
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += new AMDMove (cast (AMDObj) rpaire.where, where);       
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, where, lbin.op);
	} else {
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	}
	if (!free) REG.free (laux);
	return new TInstPaire (where, ret);
    }

    private TInstPaire visitBinopQWord (LBinop lbin, TExp twhere) {
	auto ret = new TInstList;
	bool free = false;
	AMDReg where;
	if (lbin.res is null) {
	    where = cast (AMDReg) twhere;
	    //where.resize (AMDSize.QWORD);
	} else {
	    auto wh = visitExpression (lbin.res);
	    ret += wh.what;
	    where = cast (AMDReg) wh.where;
	}
	auto laux = new AMDReg (REG.aux ());
	auto lpaire = visitExpression (lbin.left, laux);
	if (laux != lpaire.where) {
	    free = true;
	    REG.free (laux);
	}
	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    ret += new AMDMove (cast (AMDObj) rpaire.where, where);       
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, where, lbin.op);
	} else {
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	}
	if (!free) REG.free (laux);
	return new TInstPaire (where, ret);
    }

    private TInstPaire visitBinopSPrec (LBinop lbin, TExp twhere) {
	auto ret = new TInstList;
	bool free = false;
	AMDReg where;
	if (lbin.res is null) {
	    where = cast (AMDReg) twhere;
	    if (where.sizeAmd != AMDSize.SPREC)
		where = new AMDReg (REG.aux (AMDSize.SPREC));
	} else {
	    auto wh = visitExpression (lbin.res);
	    ret += wh.what;
	    where = cast (AMDReg) wh.where;
	}
	auto laux = new AMDReg (REG.aux (AMDSize.SPREC));
	auto lpaire = visitExpression (lbin.left, laux);
	if (laux != lpaire.where) {
	    free = true;
	    REG.free (laux);
	}
	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    ret += new AMDMove (cast (AMDObj) rpaire.where, where);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, where, lbin.op);
	} else {
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);	   
	}
	if (!free) REG.free (laux);
	return new TInstPaire (where, ret);
    }
    
    private TInstPaire visitBinopDPrec (LBinop lbin, TExp twhere) {
	auto ret = new TInstList;
	bool free = false, whereFree = true;
	AMDReg where, raux;
	if (lbin.res is null) {	    
	    where = cast (AMDReg) twhere;
	    if (where.sizeAmd != AMDSize.DPREC)
		where = new AMDReg (REG.aux (AMDSize.DPREC));
	    raux = where;
	    if (AMDBinop.isTest (lbin.op)) {
		where = new AMDReg (REG.aux (AMDSize.BYTE));
		whereFree = false;		
	    }
	} else {
	    auto wh = visitExpression (lbin.res);
	    ret += wh.what;
	    where = cast (AMDReg) wh.where;
	}
	
	auto laux = new AMDReg (REG.aux (AMDSize.DPREC));
	auto lpaire = visitExpression (lbin.left, laux);
	if (laux != lpaire.where) {
	    free = true;
	    REG.free (laux);
	}
	
	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	if (cast (LRegRead) lbin.right && rpaire.where != raux) {
	    ret += new AMDMove (cast (AMDObj) rpaire.where, raux);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, raux, lbin.op);
	} else {
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);	   
	}
	REG.free (raux);
	if (!whereFree) REG.free (where);
	if (!free) REG.free (laux);
	return new TInstPaire (where, ret);
    }
    
    override protected TInstPaire visitCall (LCall lcall) {
	auto inst = new TInstList;
	foreach (it ; 0 .. lcall.params.length) {
	    auto reg = new AMDReg (REG.param (it, getSize (lcall.params [it].size)));
	    auto par = visitExpression (lcall.params [it], reg);
	    inst += par.what;
	    if (par.where != reg)
		inst += new AMDMove (cast (AMDObj)par.where, reg);
	}
	
	if (lcall.name) inst += new AMDCall (lcall.name);
	else {
	    auto expr = visitExpression (lcall.dynFrame);
	    auto aux = new AMDReg (REG.getReg ("rax", lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
	    inst += expr.what;
	    inst += new AMDCallDyn (cast (AMDObj) expr.where);
	}
	
	auto retReg = new AMDReg (REG.getReg ("rax", lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
	return new TInstPaire (retReg, inst);
    }

    override protected TInstPaire visitCall (LCall lcall, TExp twhere) {
	auto where = cast (AMDReg) twhere;
	auto inst = new TInstList;
	foreach (it ; 0 .. lcall.params.length) {
	    auto reg = new AMDReg (REG.param (it, getSize (lcall.params [it].size)));
	    auto par = visitExpression (lcall.params [it], reg);
	    inst += par.what;
	    if (par.where != reg)
		inst += new AMDMove (cast (AMDObj)par.where, reg);
	}
	
	if (lcall.name) inst += new AMDCall (lcall.name);
	else {
	    auto expr = visitExpression (lcall.dynFrame);
	    auto aux = new AMDReg (REG.getReg ("rax", lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
	    inst += expr.what;
	    inst += new AMDCallDyn (cast (AMDObj) expr.where);
	}
	
	auto retReg = new AMDReg (REG.getReg ("rax", lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
	inst += new AMDMove (retReg, where);
	return new TInstPaire (where, inst);
    }    
    
    override protected TInstPaire visitCast (LCast cst) {
	auto res = this.resolve!(AMDObj) (cst);
	if (res !is null) return new TInstPaire (res, new TInstList);
	if (cst.size == LSize.DOUBLE || cst.size == LSize.FLOAT) 
	    return visitCastFlottant (cst);
	else if  (cst.what.size == LSize.DOUBLE || cst.size == LSize.FLOAT)
	    return visitCastFlottant (cst);
	auto inst = new TInstList;
	auto aux = new AMDReg (REG.aux (getSize (cst.what.size)));
	auto exp = visitExpression (cst.what, aux);
	inst += exp.what;
	REG.free (aux);
	auto reg = new AMDReg (REG.aux (getSize (cst.size)));
	if (cast (LConst) cst.what is null)
	    inst += new AMDMoveCast (cast (AMDObj) exp.where, reg);
	else if (exp.where != aux)
	    inst += new AMDMove (convToSize (reg.sizeAmd, cast (AMDObj) exp.where), reg);
	REG.free (reg);
	return new TInstPaire (reg, inst);
	
    }

    private TInstPaire visitCastFlottant (LCast cst) {
	auto inst = new TInstList;
	auto aux = new AMDReg (REG.aux (getSize (cst.what.size)));
	auto exp = visitExpression (cst.what, aux);
	inst += exp.what;
	REG.free (aux);
	auto reg = new AMDReg (REG.aux (getSize (cst.size)));
	inst += new AMDCvtt (cast (AMDObj) exp.where, reg);
	REG.free (reg);
	return new TInstPaire (reg, inst);
    }

    
    private AMDObj convToSize (AMDSize size, AMDObj elem) {
	ulong value;
	if (elem.sizeAmd == AMDSize.BYTE) value = to!ulong ((cast (AMDConstByte)elem).value);
	else if (elem.sizeAmd == AMDSize.DWORD) value = to!ulong ((cast (AMDConstDWord)elem).value);
	else if (elem.sizeAmd == AMDSize.QWORD) value = to!ulong ((cast (AMDConstQWord)elem).value);
	else assert (false);
	
	if (size == AMDSize.BYTE) return new AMDConstByte (cast (ubyte) value);
	if (size == AMDSize.DWORD) return new AMDConstDWord (cast (long) value);
	if (size == AMDSize.QWORD) return new AMDConstQWord (cast (long) value);
	assert (false);
    }
    
    override protected TInstPaire visitCast (LCast cst, TExp) {
	return visitCast (cst);
    }


    override protected TInstPaire visitUnop (LUnop unop) {
	auto inst = new TInstList;
	if (!unop.modify) {
	    auto res = new AMDReg (REG.getSwap (getSize (unop.size)));
	    auto exp = visitExpression (unop.elem, res);
	    inst += exp.what;
	    if (res != exp.where)
		inst += new AMDMove (cast (AMDObj) exp.where, res);
	    inst += new AMDUnop (res, unop.op);
	    return new TInstPaire (res, inst);
	} else {
	    auto exp = visitExpression (unop.elem);
	    inst += exp.what;
	    inst += new AMDUnop (cast (AMDObj) exp.where, unop.op);
	    return new TInstPaire (exp.where, inst);
	}
    }

    override protected TInstPaire visitUnop (LUnop unop, TExp where) {
	auto inst = new TInstList;
	auto res = cast (AMDReg) where;
	res.resize (getSize (unop.size));
	auto exp = visitExpression (unop.elem, res);
	inst += exp.what;
	if (res != exp.where)
	    inst += new AMDMove (cast (AMDObj) exp.where, res);
	inst += new AMDUnop (res, unop.op);
	return new TInstPaire (res, inst);
    }

    override protected TInstPaire visitAddr (LAddr addr) {
	auto aux = new AMDReg (REG.aux ());
	auto ret = visitAddr (addr, aux);
	REG.free (aux);
	return ret;
    }
    
    override protected TInstPaire visitAddr (LAddr addr, TExp where) {
	auto inst = new TInstList;
	if (auto read = cast (LRegRead) (addr.exp)) {
	    return visitAddrFromRegRead (addr, read, where);
	}
	auto aux = new AMDReg (REG.aux (getSize (addr.exp.size)));
	auto exp = visitExpression (addr.exp, aux);	
	auto reg = cast (AMDReg) exp.where;
	auto rbp = new AMDReg (REG.getReg ("rbp"));
	if (reg is null || !reg.isOff) assert (false, "Rhaaa, addresse sur un element constant");
	inst += exp.what;
	auto ret = new AMDReg (REG.getReg ("rax"));
	inst += new AMDLeaq (reg, ret);
	
	REG.free (aux);
	REG.free (ret);
	return new TInstPaire (ret, inst);
    }

    private TInstPaire visitAddrFromRegRead (LAddr addr, LRegRead read, TExp where) {
	auto res = this.resolve!AMDConstDWord (read.begin);
	if (res !is null && res.value == 0) {
	    if (read.data.size == read.size) {		
		return visitExpression (read.data, where);
	    } else {
		auto cst = new LCast (read.data, read.size);
		return visitExpression (cst, where);
	    }		    
	} else {
	    auto inst = new TInstList;
	    auto aux = new AMDReg (REG.aux (getSize (addr.exp.size)));
	    auto exp = visitExpression (addr.exp, aux);	
	    auto reg = cast (AMDReg) exp.where;
	    auto rbp = new AMDReg (REG.getReg ("rbp"));
	    if (reg is null || !reg.isOff) assert (false, "Rhaaa, addresse sur un element constant");
	    inst += exp.what;
	    auto ret = new AMDReg (REG.getReg ("rax"));
	    inst += new AMDLeaq (reg, ret);
	    
	    REG.free (aux);
	    REG.free (ret);
	    return new TInstPaire (ret, inst);
	}
    }
    
    private T resolve (T) (LExp exp) {
	if (auto _cb = cast (LConstByte) exp) return cast (T) (resolve (_cb));
	else if (auto _cw = cast (LConstWord) exp) return cast (T) (resolve (_cw));
	else if (auto _cdw = cast (LConstDWord) exp) return cast (T) resolve (_cdw);
	else if (auto _cqw = cast (LConstQWord) exp) return cast (T) resolve (_cqw);
	else if (auto _cd = cast (LConstDouble) exp) return cast (T) resolve (_cd);
	else if (auto _bin = cast (LBinop) exp) return cast (T) resolve (_bin);
	else if (auto _cst = cast (LCast) exp) return cast (T) resolve (_cst);
	return null;
    }

    private AMDObj resolve (LCast cst) {
	auto elem = resolve!(AMDConst) (cst.what);
	if (elem) {
	    long value = 0;
	    if (auto _e = cast (AMDConstByte) elem) value = _e.value;
	    else if (auto _e = cast (AMDConstDWord) elem) value = _e.value;
	    else if (auto _e = cast (AMDConstQWord) elem) value = _e.value;
	    else if (auto _e = cast (AMDConstDouble) elem) value = to!long (_e.value);
	    else return null;
	    auto size = getSize (cst.size);
	    if (size == AMDSize.BYTE) return new AMDConstByte (value);
	    else if (size == AMDSize.DWORD) return new AMDConstDWord (value);
	    else if (size == AMDSize.QWORD) return new AMDConstQWord (value);
	    else if (size == AMDSize.DPREC) return new AMDConstDouble (to!double (value));
	}
	return null;
    }
    
    private AMDObj resolve (LBinop op) {
	if (op.res is null) {
	    auto left = resolve!(AMDConst) (op.left);
	    auto right = resolve!(AMDConst) (op.right);
	    if (auto _l = cast (AMDConstByte) left) {
		if (auto _r = cast(AMDConstByte) right)
		    return resolveFromByte (op, _l.value, _r.value);
	    } else if (auto _l = cast (AMDConstDWord) left) {
		if (auto _r = cast(AMDConstDWord) right)
		    return resolveFromDWord (op, _l.value, _r.value);
	    } else if (auto _l = cast (AMDConstQWord) left) {
		if (auto _r = cast(AMDConstQWord) right)
		    return resolveFromQWord (op, _l.value, _r.value);
	    } else if (auto _l = cast (AMDConstDouble) left) {
		if (auto _r = cast (AMDConstDouble) right)
		    return resolveFromDouble (op, _l.value, _r.value);
	    }
	}
	return null;
    }

    private AMDObj resolve (LConstByte lb) {
	auto ret = visitConstByte (lb);
	return cast (AMDObj) ret.where;
    }

    private AMDObj resolve (LConstWord lb) {
	auto ret = visitConstWord (lb);
	return cast (AMDObj) ret.where;
    }
    
    private AMDObj resolve (LConstDWord lb) {
	auto ret = visitConstDWord (lb);
	return cast (AMDObj) ret.where;
    }
    
    private AMDObj resolve (LConstQWord lb) {
	auto ret = visitConstQWord (lb);
	return cast (AMDObj) ret.where;
    }

    private AMDObj resolve (LConstDouble lb) {
	return new AMDConstDouble (lb.value);
    }
    
    private AMDConst resolveFromByte (LBinop op, long left, long right) {
	if (op.op == Tokens.PLUS) return new AMDConstByte (left + right);
	else if (op.op == Tokens.MINUS) return new AMDConstByte (left - right);
	else if (op.op == Tokens.AND) return new AMDConstByte (left & right);
	else if (op.op == Tokens.PIPE) return new AMDConstByte (left | right);
	else if (op.op == Tokens.STAR) return new AMDConstByte (left * right);
	else if (op.op == Tokens.DIV) {
	    if (right == 0) throw new FloatingPointException (op.locus);
	    return new AMDConstByte (left / right);
	}
	else if (op.op == Tokens.LEFTD) return new AMDConstByte (left << right);
	else if (op.op == Tokens.RIGHTD) return new AMDConstByte (left >> right);
	else if (op.op == Tokens.XOR) return new AMDConstByte (left ^ right);
	else if (op.op == Tokens.SUP) return new AMDConstByte (left > right);
	else if (op.op == Tokens.SUP_EQUAL) return new AMDConstByte (left >= right);
	else if (op.op == Tokens.INF) return new AMDConstByte (left < right);
	else if (op.op == Tokens.INF_EQUAL) return new AMDConstByte (left <= right);
	else if (op.op == Tokens.DEQUAL) return new AMDConstByte (left == right);
	else if (op.op == Tokens.NOT_EQUAL) return new AMDConstByte (left != right);
	else assert (false, "TODO " ~ op.op.descr);
    }

    private AMDConst resolveFromDouble (LBinop op, double left, double right) {
	if (op.op == Tokens.PLUS) return new AMDConstDouble (left + right);
	else if (op.op == Tokens.MINUS) return new AMDConstDouble (left - right);
	else if (op.op == Tokens.STAR) return new AMDConstDouble (left * right);
	else if (op.op == Tokens.DIV) {
	    if (right == 0.0) throw new FloatingPointException (op.locus);
	    return new AMDConstDouble (left / right);
	}
	else if (op.op == Tokens.SUP) return new AMDConstDouble (left > right);
	else if (op.op == Tokens.SUP_EQUAL) return new AMDConstDouble (left >= right);
	else if (op.op == Tokens.INF) return new AMDConstDouble (left < right);
	else if (op.op == Tokens.INF_EQUAL) return new AMDConstDouble (left <= right);
	else if (op.op == Tokens.DEQUAL) return new AMDConstDouble (left == right);
	else if (op.op == Tokens.NOT_EQUAL) return new AMDConstDouble (left != right);
	else assert (false, "TODO " ~ op.op.descr);
    }
    
    private AMDConst resolveFromDWord (LBinop op, long left, long right) {
	if (op.op == Tokens.PLUS) return new AMDConstDWord (left + right);
	else if (op.op == Tokens.MINUS) return new AMDConstDWord (left - right);
	else if (op.op == Tokens.AND) return new AMDConstDWord (left & right);
	else if (op.op == Tokens.PIPE) return new AMDConstDWord (left | right);
	else if (op.op == Tokens.STAR) return new AMDConstDWord (left * right);
	else if (op.op == Tokens.DIV) {
	    if (right == 0) throw new FloatingPointException (op.locus);
	    return new AMDConstDWord (left / right);
	}
	else if (op.op == Tokens.LEFTD) return new AMDConstDWord (left << right);
	else if (op.op == Tokens.RIGHTD) return new AMDConstDWord (left >> right);
	else if (op.op == Tokens.XOR) return new AMDConstDWord (left ^ right);
	else if (op.op == Tokens.SUP) return new AMDConstDWord (left > right);
	else if (op.op == Tokens.SUP_EQUAL) return new AMDConstDWord (left >= right);
	else if (op.op == Tokens.INF) return new AMDConstDWord (left < right);
	else if (op.op == Tokens.INF_EQUAL) return new AMDConstDWord (left <= right);
	else if (op.op == Tokens.DEQUAL) return new AMDConstDWord (left == right);
	else if (op.op == Tokens.NOT_EQUAL) return new AMDConstDWord (left != right);
	else assert (false, "TODO " ~ op.op.descr);
    }    

    private AMDConst resolveFromQWord (LBinop op, long left, long right) {
	if (op.op == Tokens.PLUS) return new AMDConstQWord (left + right);
	else if (op.op == Tokens.MINUS) return new AMDConstQWord (left - right);
	else if (op.op == Tokens.AND) return new AMDConstQWord (left & right);
	else if (op.op == Tokens.PIPE) return new AMDConstQWord (left | right);
	else if (op.op == Tokens.STAR) return new AMDConstQWord (left * right);
	else if (op.op == Tokens.DIV) {
	    if (right == 0) throw new FloatingPointException (op.locus);
	    return new AMDConstQWord (left / right);
	}
	else if (op.op == Tokens.LEFTD) return new AMDConstQWord (left << right);
	else if (op.op == Tokens.RIGHTD) return new AMDConstQWord (left >> right);
	else if (op.op == Tokens.XOR) return new AMDConstQWord (left ^ right);
	else if (op.op == Tokens.SUP) return new AMDConstQWord (left > right);
	else if (op.op == Tokens.SUP_EQUAL) return new AMDConstQWord (left >= right);
	else if (op.op == Tokens.INF) return new AMDConstQWord (left < right);
	else if (op.op == Tokens.INF_EQUAL) return new AMDConstQWord (left <= right);
	else if (op.op == Tokens.DEQUAL) return new AMDConstQWord (left == right);
	else if (op.op == Tokens.NOT_EQUAL) return new AMDConstQWord (left != right);
	else assert (false, "TODO " ~ op.op.descr);
    }    
    
    override protected TInstPaire visitConstByte (LConstByte val) {
	return new TInstPaire (new AMDConstByte (val.value), new TInstList);
    }

    override protected TInstPaire visitConstByte (LConstByte val, TExp) {
	return visitConstByte (val);
    }
    
    override protected TInstPaire visitConstWord (LConstWord) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitConstDWord (LConstDWord val, TExp) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstDWord (val.value * (getSize (val.mult).size)), new TInstList);
	}
	return new TInstPaire (new AMDConstDWord (val.value), new TInstList);	
    }

    override protected TInstPaire visitConstDWord (LConstDWord val) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstDWord (val.value * (getSize (val.mult).size)), new TInstList);
	}
	return new TInstPaire (new AMDConstDWord (val.value), new TInstList);	
    }

    override protected TInstPaire visitConstQWord (LConstQWord val) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstQWord (val.value * (getSize (val.mult).size)), new TInstList);
	}
	return new TInstPaire (new AMDConstQWord (val.value), new TInstList);
    }

    override protected TInstPaire visitConstQWord (LConstQWord val, TExp) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstQWord (val.value * (getSize (val.mult).size)), new TInstList);
	}
	return new TInstPaire (new AMDConstQWord (val.value), new TInstList);
    }
    
    override protected TInstPaire visitConstFloat (LConstFloat) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitConstDouble (LConstDouble ld) {
	return new TInstPaire (new AMDConstDouble (ld.value), new TInstList);
    }

    override protected TInstPaire visitConstDouble (LConstDouble ld, TExp) {
	return new TInstPaire (new AMDConstDouble (ld.value), new TInstList);
    }
    
    override protected TInstPaire visitConstString (LConstString lstr) {
	auto str = new AMDConstString (lstr.value);
	return new TInstPaire (str, new TInstList);
    }

    override protected TInstPaire visitConstString (LConstString lstr, TExp) {
	auto str = new AMDConstString (lstr.value);
	return new TInstPaire (str, new TInstList);
    }

    override protected TInstPaire visitConstFunc (LConstFunc cfc, TExp) {
	auto func = new AMDConstFunc (cfc.name);
	return new TInstPaire (func, new TInstList);
    }
    
    override protected TInstPaire visitConstFunc (LConstFunc cfc) {
	auto func = new AMDConstFunc (cfc.name);
	return new TInstPaire (func, new TInstList);
    }
    
    override protected TInstPaire visit (LReg reg) {
	return new TInstPaire (new AMDReg (reg.id, getSize (reg.size)), new TInstList);
    }

    override protected TInstPaire  visit (LReg reg, TExp) {
	return visit (reg);
    }
    
}
