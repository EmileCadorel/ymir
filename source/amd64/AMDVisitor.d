module amd64.AMDVisitor;
import target.TVisitor, amd64.AMDReg, target.TInstList;
import amd64.AMDStd, amd64.AMDConst, amd64.AMDLabel;
import amd64.AMDMove, amd64.AMDBinop;
import syntax.Tokens, amd64.AMDSize, amd64.AMDFrame, std.conv;
import amd64.AMDObj, amd64.AMDSysCall, amd64.AMDJumps;
import amd64.AMDCast, amd64.AMDCall, amd64.AMDUnop, amd64.AMDLeaq;
import std.math, amd64.AMDLocus;


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
	auto reg = (cast (AMDReg) exp.where).clone (AMDSize.BYTE);
	inst += new AMDBinop (new AMDConstByte (0), reg, Tokens.DEQUAL);	
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
		    auto aux = new AMDReg (REG.getReg ("r14", lreg.sizeAmd));
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
	auto rreg = cast (AMDReg) right.where;
	if (rreg !is null && rreg.isOff) {
	    inst += right.what;
	    auto aux = new AMDReg (REG.getReg ("r14", rreg.sizeAmd));
	    inst += new AMDMove (cast (AMDObj) right.where, aux);
	    inst += left.what;
	    inst += new AMDMove (aux, cast (AMDObj) left.where);
	    REG.free (aux);
	} else {
	    inst += right.what + left.what;
	    inst += new AMDMove (cast (AMDObj) right.where, cast (AMDObj) left.where);
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
	fin.resize (getSize (lread.size));
	return new TInstPaire (fin, inst);
    }

    override protected TInstPaire visitRegRead (LRegRead lread, TExp) {
	auto exp = visitExpression (lread.data);
	auto inst = new TInstList;
	inst += exp.what;
	auto aux = new AMDReg (REG.getReg ("r13", (cast(AMDObj)exp.where).sizeAmd));
	inst += new AMDMove ((cast(AMDObj)exp.where), aux);
	auto fin = new AMDReg (aux.name, aux.sizeAmd);
	fin.isOff = true;
	fin.offset = - cast (long) lread.begin;
	fin.resize (getSize (lread.size));
	return new TInstPaire (fin, inst);
    }

    
    override protected TReg visitReg (LReg) {
	assert (false, "TODO");
    }

    override protected TInstPaire visitBinop (LBinop lbin) {
	auto size = getSize (lbin.left.size);
	TInstPaire ret;
	auto where = new AMDReg (REG.aux (size));
	if (size == AMDSize.BYTE) ret = visitBinopByte (lbin, where);
	else if (size == AMDSize.WORD) ret = visitBinopWord (lbin, where);
	else if (size == AMDSize.DWORD) ret = visitBinopDWord (lbin, where);
	else if (size == AMDSize.QWORD) ret = visitBinopQWord (lbin, where);
	else assert (false, "TODO");
	REG.freeAll ();
	return ret;
    }
    
    override protected TInstPaire visitBinop  (LBinop lbin, TExp where) {
	auto size = getSize (lbin.left.size);
	if (size == AMDSize.BYTE) return visitBinopByte (lbin, where);
	else if (size == AMDSize.WORD) return visitBinopWord (lbin, where);
	else if (size == AMDSize.DWORD) return visitBinopDWord (lbin, where);
	else if (size == AMDSize.QWORD) return visitBinopQWord (lbin, where);
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
	if (!free) REG.free (laux);
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    ret += new AMDMove (cast (AMDObj) rpaire.where, where);       
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, where, lbin.op);
	} else {
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	}

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
	auto lpaire = visitExpression (lbin.left, laux);
	if (laux != lpaire.where) {
	    free = true;
	    REG.free (laux);
	}
	auto rpaire = visitExpression (lbin.right, where);
	ret += rpaire.what;
	if (!free) REG.free (laux);
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    ret += new AMDMove (cast (AMDObj) rpaire.where, where);       
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, where, lbin.op);
	} else {
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	} 
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
	if (!free) REG.free (laux);
	if (cast (LRegRead) lbin.right && rpaire.where != where) {
	    ret += new AMDMove (cast (AMDObj) rpaire.where, where);       
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, where, lbin.op);
	} else {
	    ret += lpaire.what;
	    ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj) rpaire.where, lbin.op);
	} 
	return new TInstPaire (where, ret);
    }
    
    override protected TInstPaire visitBinopSized (LBinopSized lbin) {
	auto ret = new TInstList;
	bool free = false;
	auto where = new AMDReg (REG.aux (getSize (lbin.size)));
	where.resize (AMDSize.QWORD);
	auto laux = new AMDReg (REG.aux ());
	auto lpaire = visitExpression (lbin.left, laux);
	if (laux != lpaire.where) {
	    free = true;
	    REG.free (laux);
	}
	auto rpaire = visitExpression (lbin.right, where);
	ret += lpaire.what + rpaire.what;
	if (!free) REG.free (laux);
	ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj)rpaire.where, lbin.op);
	REG.free (where);
	return new TInstPaire (where, ret);
    }

    override protected TInstPaire visitBinopSized (LBinopSized lbin, TExp twhere) {
	auto ret = new TInstList;
	bool free = false;	
	auto where = (cast (AMDReg) twhere);
	where.resize (AMDSize.QWORD);
	auto laux = new AMDReg (REG.aux ());
	auto lpaire = visitExpression (lbin.left, laux);
	if (laux != lpaire.where) {
	    free = true;
	    REG.free (laux);
	}
	auto rpaire = visitExpression (lbin.right, where);
	ret += lpaire.what + rpaire.what;
	if (!free) REG.free (laux);
	ret += new AMDBinop (where, cast (AMDObj) lpaire.where, cast (AMDObj)rpaire.where, lbin.op);
	return new TInstPaire (where, ret);
    }
    
    override protected TInstPaire visitCall (LCall lcall) {
	auto inst = new TInstList;
	auto call = new AMDCall (lcall.name);
	foreach (it ; 0 .. lcall.params.length) {
	    auto reg = new AMDReg (REG.param (it, getSize (lcall.params [it].size)));
	    auto par = visitExpression (lcall.params [it], reg);
	    inst += par.what;
	    if (par.where != reg)
		inst += new AMDMove (cast (AMDObj)par.where, reg);
	}
	
	inst += call;
	auto retReg = new AMDReg (REG.getReg ("rax"));
	return new TInstPaire (retReg, inst);
    }

    override protected TInstPaire visitCall (LCall lcall, TExp twhere) {
	auto where = cast (AMDReg) twhere;
	auto inst = new TInstList;
	auto call = new AMDCall (lcall.name);
	foreach (it ; 0 .. lcall.params.length) {
	    auto reg = new AMDReg (REG.param (it, getSize (lcall.params [it].size)));
	    auto par = visitExpression (lcall.params [it], reg);
	    inst += par.what;
	    if (par.where != reg)
		inst += new AMDMove (cast (AMDObj)par.where, reg);
	}
	
	inst += call;
	auto retReg = new AMDReg (REG.getReg ("rax", where.sizeAmd));
	inst += new AMDMove (retReg, where);
	return new TInstPaire (where, inst);
    }    
    
    
    override protected TInstPaire visitCast (LCast cst) {
	if (cst.size < cst.what.size) {
	    auto reg = new AMDReg (REG.aux (getSize (cst.what.size)));
	    auto inst = new TInstList;
	    auto aux = reg.clone (getSize (cst.what.size));
	    auto exp = visitExpression (cst.what, aux);
	    inst += exp.what;
	    if (exp.where != aux)
		inst += new AMDMove (cast (AMDObj) exp.where, aux);
	    auto ret = reg.clone (getSize (cst.size));
	    return new TInstPaire (ret, inst);
	} else {
	    auto reg = new AMDReg (REG.aux (getSize (cst.size)));
	    auto inst = new TInstList;
	    auto aux = reg.clone (getSize (cst.what.size));
	    auto exp = visitExpression (cst.what, aux);
	    inst += exp.what;
	    if (cast (LConst) cst.what is null)
		inst += new AMDMoveCast (cast (AMDObj) exp.where, reg);
	    else if (exp.where != aux)
		inst += new AMDMove (convToSize (reg.sizeAmd, cast (AMDObj) exp.where), reg);
	    return new TInstPaire (reg, inst);
	}
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
	auto res = new AMDReg (REG.getReg ("r14", getSize (unop.size)));
	auto exp = visitExpression (unop.elem, res);
	inst += exp.what;
	if (res != exp.where)
	    inst += new AMDMove (cast (AMDObj) exp.where, res);
	inst += new AMDUnop (res, unop.op);
	return new TInstPaire (res, inst);
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
	auto aux = new AMDReg (REG.aux (getSize (addr.exp.size)));
	auto exp = visitExpression (addr.exp, aux);
	auto reg = cast (AMDReg) exp.where;
	if (reg is null || !reg.isOff) assert (false, "Rhaaa, addresse sur un element constant");
	inst += exp.what;
	inst += new AMDMove (new AMDReg (REG.getReg ("rbp")), cast (AMDObj) where);
	inst += new AMDBinop (new AMDConstQWord (-reg.offset),
			      cast (AMDObj) where, Tokens.PLUS);

	// On pourrait mettre un leaq mais je vois pas l'interet
	// vu qu'il faut quand meme un registre intermediaire
	 
	REG.free (aux);
	return new TInstPaire (where, inst);
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
	return new TInstPaire (new AMDConstDWord (val.value), new TInstList);	
    }

    override protected TInstPaire visitConstDWord (LConstDWord val) {
	return new TInstPaire (new AMDConstDWord (val.value), new TInstList);	
    }

    override protected TInstPaire visitConstQWord (LConstQWord val) {
	return new TInstPaire (new AMDConstQWord (val.value), new TInstList);
    }

    override protected TInstPaire visitConstQWord (LConstQWord val, TExp) {
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

    override protected TInstPaire visitConstString (LConstString lstr, TExp) {
	auto str = new AMDConstString (lstr.value);
	return new TInstPaire (str, new TInstList);
    }
    
    override protected TInstPaire visit (LReg reg) {
	return new TInstPaire (new AMDReg (reg.id, getSize (reg.size)), new TInstList);
    }

    override protected TInstPaire  visit (LReg reg, TExp) {
	return visit (reg);
    }
    
}
