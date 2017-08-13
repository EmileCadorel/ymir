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
	auto stack = new AMDConstDecimal (0, AMDSize.QWORD);
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
	ulong nbInt, nbFloat;
	auto currOff = 0;
	foreach (it ; 0 .. frame.args.length) {
	    auto reg = new AMDReg (REG.param (nbInt, nbFloat, getSize (frame.args[it].size)));
	    if (reg.isOff) {
		if (currOff == 0) currOff = 8 + (8 * cast (int) (frame.args.length - it));
		reg = new AMDReg (getSize (frame.args [it].size), currOff);
		currOff -= 8;
	    }
	    entry.inst += new AMDMove (reg,
				       new AMDReg (frame.args[it].id,
						   getSize (frame.args[it].size)));
	}
	entry.inst += lbl.inst;
	entry.inst += visit(frame.returnLbl);
	if (frame.returnReg !is null) {
	    auto ret = new AMDReg (REG.getRet (getSize (frame.returnReg.size)));
	    auto left = visitExpression (frame.returnReg, ret);
	    entry.inst += left.what;
	    if (left.where != ret)
		entry.inst += new AMDMove (cast (AMDObj)left.where, ret);
	}
	
	stack.value = AMDReg.globalOff + (16 - AMDReg.globalOff % 16);
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
	    inst += new AMDBinop (new AMDConstDecimal (0, AMDSize.BYTE), reg, Tokens.DEQUAL);
	} else {
	    auto reg = new AMDReg (REG.aux (AMDSize.BYTE));
	    inst += new AMDMove (cast (AMDObj) exp.where, reg);
	    inst += new AMDBinop (new AMDConstDecimal (0, AMDSize.BYTE), reg, Tokens.DEQUAL);
	}
	inst += new AMDJne (lj.id);
	return inst;
    }

    override protected TInstList visitSys (LSysCall lsys) {
	auto inst = new TInstList;
	auto sys = new AMDSysCall (lsys.name);
	ulong nbInt, nbFloat;
	foreach (it ; 0 .. lsys.params.length) {
	    auto par = visitExpression (lsys.params [it]);
	    auto reg = new AMDReg (REG.param (nbInt, nbFloat, (cast(AMDObj)par.where).sizeAmd));
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
	auto right = visitExpression (write.right);
	auto rreg = cast (AMDObj) right.where;
	inst += right.what;
	if (cast (AMDConst) rreg is null) {
	    auto aux = new AMDReg (REG.aux (rreg.sizeAmd));
	    auto left = visitExpression (write.left);
	    inst += new AMDMove (cast (AMDObj) right.where, aux);
	    inst += left.what;
	    inst += new AMDMove (aux, cast (AMDObj) left.where);
	    REG.free (aux);
	} else {
	    auto left = visitExpression (write.left);
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
	auto res = this.resolve!(AMDConstDecimal) (lread.begin);
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
	if (auto _res = cast (AMDConstDecimal) (res))
	    fin.offset = -_res.value;
	else if (auto _res = cast (AMDConstDecimal) (res))
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
	if (size == AMDSize.BYTE || size == AMDSize.UBYTE) ret = visitBinopByte (lbin, where);
	else if (size == AMDSize.WORD || size == AMDSize.UWORD) ret = visitBinopWord (lbin, where);
	else if (size == AMDSize.DWORD || size == AMDSize.UDWORD) ret = visitBinopDWord (lbin, where);
	else if (size == AMDSize.QWORD || size == AMDSize.UQWORD) ret = visitBinopQWord (lbin, where);
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
	if (size == AMDSize.BYTE || size == AMDSize.UBYTE) return visitBinopByte (lbin, where);
	else if (size == AMDSize.WORD || size == AMDSize.UWORD) return visitBinopWord (lbin, where);
	else if (size == AMDSize.DWORD || size == AMDSize.UDWORD) return visitBinopDWord (lbin, where);
	else if (size == AMDSize.QWORD || size == AMDSize.UQWORD) return visitBinopQWord (lbin, where);
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
	auto rpaire = visitExpression (lbin.right, where);
	
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    ret += rpaire.what;
	    auto aux = new AMDReg (REG.aux ((cast (AMDObj)rpaire.where).sizeAmd));
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += new AMDMove (cast (AMDObj) rpaire.where, aux);		
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, aux, lbin.op);
	    REG.free (aux);	    
	} else {
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += lpaire.what;
	    ret += rpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	}
	if (!free) REG.free (laux);
	return new TInstPaire (where, ret);
    }

    private TInstPaire visitBinopWord (LBinop lbin, TExp twhere) {
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

	auto laux = new AMDReg (REG.aux (AMDSize.WORD));
	import std.stdio;
	
	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    auto aux = new AMDReg (REG.aux ((cast (AMDObj)rpaire.where).sizeAmd));
	    ret += new AMDMove (cast (AMDObj) rpaire.where, aux);
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, aux, lbin.op);
	    REG.free (aux);	    
	} else {
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	}
	if (!free) REG.free (laux);
	return new TInstPaire (where, ret);
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
	import std.stdio;
	
	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    auto aux = new AMDReg (REG.aux ((cast (AMDObj)rpaire.where).sizeAmd));
	    ret += new AMDMove (cast (AMDObj) rpaire.where, aux);
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, aux, lbin.op);
	    REG.free (aux);	    
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

	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	REG.reserve (cast (AMDReg) rpaire.where);
	auto laux = new AMDReg (REG.aux ());
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    auto aux = new AMDReg (REG.aux ((cast (AMDObj)rpaire.where).sizeAmd));
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += new AMDMove (cast (AMDObj) rpaire.where, aux);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, aux, lbin.op);
	    REG.free (aux);	    
	} else {
	    auto lpaire = visitExpression (lbin.left, laux);
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	}
	REG.free (cast (AMDReg) rpaire.where);
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
	ulong nbInt, nbFloat, nbPush = 0;
	foreach (it ; 0 .. lcall.params.length) {
	    auto reg = new AMDReg (REG.param (nbInt, nbFloat, getSize (lcall.params [it].size)));
	    auto par = visitExpression (lcall.params [it], reg);
	    inst += par.what;
	    if (reg.isOff) {
		nbPush += 1;
		if (cast (AMDConstDecimal) par.where || cast (AMDConstUDecimal) par.where) {
		    auto cst = cast (AMDConstDecimal) par.where;
		    if (cst !is null) {
			inst += new AMDPush (new AMDConstDecimal (cst.value, AMDSize.QWORD));
		    } else {
			auto cst2 = cast (AMDConstDecimal) par.where;
			inst += new AMDPush (new AMDConstUDecimal (cst.value, AMDSize.UQWORD));
		    }
		} else if ((cast(AMDObj)par.where).sizeAmd.size != AMDSize.QWORD.size) {
		    auto aux = new AMDReg (REG.aux (AMDSize.QWORD));
		    inst += new AMDMoveCast (cast (AMDObj) par.where, aux);
		    inst += new AMDPush (aux);
	    } else inst += new AMDPush (cast (AMDObj) par.where);
	    } else if (par.where != reg)		
		inst += new AMDMove (cast (AMDObj)par.where, reg);
	}
	
	if (nbPush % 2 == 1) {
	    inst = new TInstList (new AMDBinop (new AMDConstDecimal (8, AMDSize.QWORD), new AMDReg (REG.getReg ("rsp")), Tokens.MINUS)) + inst;				  
	}
	
	if (lcall.isVariadic) {
	    auto rax = new AMDReg (REG.getReg ("rax"));	    
	    inst += new AMDMove (new AMDConstDecimal (nbFloat, AMDSize.QWORD), rax);
	}
	
	if (lcall.name) inst += new AMDCall (lcall.name);
	else {
	    auto expr = visitExpression (lcall.dynFrame);
	    auto aux = new AMDReg (REG.getRet (lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
	    inst += expr.what;
	    inst += new AMDCallDyn (cast (AMDObj) expr.where);
	}
	
	auto retReg = new AMDReg (REG.getRet (lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
	return new TInstPaire (retReg, inst);
    }

    override protected TInstPaire visitCall (LCall lcall, TExp twhere) {
	auto where = cast (AMDReg) twhere;
	auto inst = new TInstList;
	ulong nbInt, nbFloat;	
	foreach (it ; 0 .. lcall.params.length) {
	    auto reg = new AMDReg (REG.param (nbInt, nbFloat, getSize (lcall.params [it].size)));
	    auto par = visitExpression (lcall.params [it], reg);
	    inst += par.what;
	    if (par.where != reg)
		inst += new AMDMove (cast (AMDObj)par.where, reg);
	}
	
	if (lcall.isVariadic) {
	    auto rax = new AMDReg (REG.getReg ("rax"));	    
	    inst += new AMDMove (new AMDConstDecimal (nbFloat, AMDSize.QWORD), rax);
	}

	if (lcall.name) inst += new AMDCall (lcall.name);
	else {
	    auto expr = visitExpression (lcall.dynFrame);
	    auto aux = new AMDReg (REG.getRet (lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
	    inst += expr.what;
	    if (auto cst = cast (AMDConstFunc) expr.where)
		inst += new AMDCall (cst.name);
	    else 
		inst += new AMDCallDyn (cast (AMDObj) expr.where);
	}
	
	auto retReg = new AMDReg (REG.getRet (lcall.size != LSize.NONE ? getSize (lcall.size) : AMDSize.QWORD));
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
	else inst += new AMDMoveCast (aux, reg);
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
	if (auto dec = cast (AMDConstDecimal) elem) return new AMDConstDecimal (dec.value, size);
	else if (auto udec = cast (AMDConstUDecimal) elem) return new AMDConstUDecimal (udec.value, size);
	else assert (false);
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
	if (unop.op != Tokens.SQRT) {
	    auto inst = new TInstList;
	    auto res_ = cast (AMDReg) where;
	    auto res = res_.clone (getSize (unop.size));
	    auto exp = visitExpression (unop.elem, res);
	    inst += exp.what;
	    if (res != exp.where)
		inst += new AMDMove (cast (AMDObj) exp.where, res);
	    inst += new AMDUnop (res, unop.op);
	    return new TInstPaire (res, inst);
	} else {
	    auto inst = new TInstList;
	    auto res = new AMDReg (REG.aux (getSize (unop.elem.size)));
	    auto exp = visitExpression (unop.elem, res);
	    REG.free (res);
	    inst += exp.what;	    
	    if (res != exp.where && !res.isOff)
		inst += new AMDMove (cast (AMDObj) exp.where, res);
	    if (res.isOff) {
		auto aux = new AMDReg (REG.getSwap (res.sizeAmd));
		inst += new AMDMove (cast (AMDObj) exp.where, aux);
		inst += new AMDUnop (aux, unop.op);
		inst += new AMDMove (aux, res);
		return new TInstPaire (res, inst);
	    } 
	    inst += new AMDUnop (res, unop.op);
	    return new TInstPaire (res, inst);
	}
    }

    override protected TInstPaire visitAddr (LAddr addr) {
	auto aux = new AMDReg (REG.aux ());
	auto ret = visitAddr (addr, aux);
	REG.free (aux);
	return ret;
    }

    override protected TInstPaire visitReserve (LReserve res) {
	auto size = resolve!AMDConstDecimal (res.length);
	auto aux = REG.reserveSpace (res.id.id, size);
	return new TInstPaire (aux, new TInstList);
    }

    override protected TInstPaire visitReserve (LReserve res, TExp) {
	auto size = resolve!AMDConstDecimal (res.length);
	auto aux = REG.reserveSpace (res.id.id, size);
	return new TInstPaire (aux, new TInstList);
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
	if ((reg is null || !reg.isOff) && !cast (AMDStaticReg) exp.where) assert (false, "Rhaaa, addresse sur un element constant " ~ addr.toString);
	inst += exp.what;
	auto ret = new AMDReg (REG.getReg ("rax"));
	inst += new AMDLeaq (reg, ret);
	
	REG.free (aux);
	REG.free (ret);
	return new TInstPaire (ret, inst);
    }

    private TInstPaire visitAddrFromRegRead (LAddr addr, LRegRead read, TExp where) {
	auto res = this.resolve!AMDConstDecimal (read.begin);
	if (res !is null && res.value == 0) {
	    if (read.data.size == read.size) {		
		return visitExpression (read.data, where);
	    } else {
		auto cst = new LCast (read.data, LSize.ULONG);
		auto ret = visitExpression (cst, where);
		return ret;
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
	if (auto _cd = cast (LConstDecimal) exp) return cast (T) (resolve (_cd));
	else if (auto _cud = cast (LConstUDecimal) exp) return cast (T) (resolve (_cud));
	else if (auto _cd = cast (LConstDouble) exp) return cast (T) resolve (_cd);
	else if (auto _bin = cast (LBinop) exp) return cast (T) resolve (_bin);
	else if (auto _cst = cast (LCast) exp) return cast (T) resolve (_cst);
	return null;
    }

    private AMDObj resolve (LCast cst) {
	auto elem = resolve!(AMDConst) (cst.what);
	if (elem) {
	    long value = 0;
	    if (auto _e = cast (AMDConstDecimal) elem) value = _e.value;
	    else if (auto _e = cast (AMDConstDouble) elem) value = to!long (_e.value);
	    else return null;
	    auto size = getSize (cst.size);
	    if (size != AMDSize.DPREC && size != AMDSize.SPREC) return new AMDConstDecimal (value, size);
	    else if (size == AMDSize.DPREC) return new AMDConstDouble (to!double (value));
	}
	return null;
    }
    
    private AMDObj resolve (LBinop op) {
	if (op.res is null) {
	    auto left = resolve!(AMDConst) (op.left);
	    auto right = resolve!(AMDConst) (op.right);
	    if (auto _l = cast (AMDConstDecimal) left) {
		if (auto _r = cast(AMDConstDecimal) right)
		    return resolveFromDecimal (op, _l.value, _r.value, _r.sizeAmd);
	    } else if (auto _l = cast (AMDConstDouble) left) {
		if (auto _r = cast (AMDConstDouble) right)
		    return resolveFromDouble (op, _l.value, _r.value);
	    }
	}
	return null;
    }

    private AMDObj resolve (LConstDecimal lb) {
	auto ret = visitConstDecimal (lb);
	return cast (AMDObj) ret.where;
    }

    private AMDObj resolve (LConstUDecimal lb) {
	auto ret = visitConstUDecimal (lb);
	return cast (AMDObj) ret.where;
    }

    private AMDObj resolve (LConstDouble lb) {
	return new AMDConstDouble (lb.value);
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
    
    private AMDConst resolveFromDecimal (LBinop op, long left, long right, AMDSize size) {
	if (op.op == Tokens.PLUS) return new AMDConstDecimal (left + right, size);
	else if (op.op == Tokens.MINUS) return new AMDConstDecimal (left - right, size);
	else if (op.op == Tokens.AND) return new AMDConstDecimal (left & right, size);
	else if (op.op == Tokens.PIPE) return new AMDConstDecimal (left | right, size);
	else if (op.op == Tokens.STAR) return new AMDConstDecimal (left * right, size);
	else if (op.op == Tokens.DIV) {
	    if (right == 0) throw new FloatingPointException (op.locus);
	    return new AMDConstDecimal (left / right, size);
	}
	else if (op.op == Tokens.LEFTD) return new AMDConstDecimal (left << right, size);
	else if (op.op == Tokens.RIGHTD) return new AMDConstDecimal (left >> right, size);
	else if (op.op == Tokens.XOR) return new AMDConstDecimal (left ^ right, size);
	else if (op.op == Tokens.SUP) return new AMDConstDecimal (left > right, size);
	else if (op.op == Tokens.SUP_EQUAL) return new AMDConstDecimal (left >= right, size);
	else if (op.op == Tokens.INF) return new AMDConstDecimal (left < right, size);
	else if (op.op == Tokens.INF_EQUAL) return new AMDConstDecimal (left <= right, size);
	else if (op.op == Tokens.DEQUAL) return new AMDConstDecimal (left == right, size);
	else if (op.op == Tokens.NOT_EQUAL) return new AMDConstDecimal (left != right, size);
	else if (op.op == Tokens.DPIPE) return new AMDConstDecimal (left || right, size);
	else if (op.op == Tokens.DAND) return new AMDConstDecimal (left && right, size);
	else assert (false, "TODO " ~ op.op.descr);
    }    
    
    override protected TInstPaire visitConstUDecimal (LConstUDecimal val) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstUDecimal (val.value * (getSize (val.mult).size), getSize (val.size)), new TInstList);	   
	} else {
	    return new TInstPaire (new AMDConstUDecimal (val.value, getSize (val.size)), new TInstList);
	}
    }

    override protected TInstPaire visitConstDecimal (LConstDecimal val) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstDecimal (val.value * (getSize (val.mult).size), getSize (val.size)), new TInstList);	   
	} else {
	    return new TInstPaire (new AMDConstDecimal (val.value, getSize (val.size)), new TInstList);
	}
    }
    
    override protected TInstPaire visitConstUDecimal (LConstUDecimal val, TExp) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstUDecimal (val.value * (getSize (val.mult).size), getSize (val.size)), new TInstList);	   
	} else {
	    return new TInstPaire (new AMDConstUDecimal (val.value, getSize (val.size)), new TInstList);
	}
    }

    override protected TInstPaire visitConstDecimal (LConstDecimal val, TExp) {
	if (val.mult != LSize.NONE) {
	    return new TInstPaire (new AMDConstDecimal (val.value * (getSize (val.mult).size), getSize (val.size)), new TInstList);	   
	} else {
	    return new TInstPaire (new AMDConstDecimal (val.value, getSize (val.size)), new TInstList);
	}
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
	import amd64.AMDRodata;
	if (reg.isStatic) {
	    if (!AMDData.exists (reg.name ~ reg.id.to!string)) {
		auto list = new TInstList;		
		AMDData.insts += new AMDAlign (8);
		AMDData.insts += new AMDType (reg.name ~ '.' ~ reg.id.to!string, AMDTypes.OBJECT);
		AMDData.insts += new AMDInstSize (reg.name ~ '.' ~ reg.id.to!string, getSize (reg.size).size.to!string);
		auto label = new AMDLabel (reg.name ~ '.' ~ reg.id.to!string, new TInstList);
		label.inst +=  new AMDLong ("0");
		AMDData.insts += label;
		AMDData.add (reg.name ~ reg.id.to!string);
	    }
	    return new TInstPaire (new AMDStaticReg (getSize (reg.size), reg.name ~ '.' ~ reg.id.to!string), new TInstList);
	} else 
	    return new TInstPaire (new AMDReg (reg.id, getSize (reg.size)), new TInstList);
    }

    override protected TInstPaire  visit (LReg reg, TExp) {
	return visit (reg);
    }
    
}
