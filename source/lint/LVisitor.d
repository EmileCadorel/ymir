module lint.LVisitor;
import semantic.pack.FrameTable, semantic.pack.Frame;
import lint.LFrame, lint.LInstList, lint.LLabel, lint.LReg;
import semantic.types.VoidInfo, lint.LSize;
import lint.LConst, lint.LRegRead, lint.LJump;
import semantic.pack.Symbol, lint.LGoto, lint.LWrite, lint.LCall;
import ast.all, std.container, std.conv, lint.LExp, lint.LSysCall;
import semantic.types.StringUtils, lint.LLocus, semantic.types.ArrayInfo;
import semantic.types.ArrayUtils, std.math, std.stdio;
import lint.LBinop, syntax.Tokens, semantic.types.PtrFuncInfo;

class LVisitor {

    private LLabel [Instruction] _endLabels;
    
    Array!LFrame visit () {
	Array!LFrame frames;
	foreach (it ; FrameTable.instance.finals) {
	    frames.insertBack (this.visit (it));
	}
	
	foreach (key, value ; LFrame.preCompiled) {
	    frames.insertBack (value);
	}
	
	return frames;
    }

    private LFrame visit (FinalFrame semFrame) {
	LLabel entry = new LLabel, end = new LLabel;
	LReg retReg = null;
	LReg.lastId = semFrame.last;
	
	if (semFrame.type !is null && cast(VoidInfo)semFrame.type.type is null) {
	    retReg = new LReg (semFrame.type.type.size);
	}

	entry.insts = new LInstList;
	Array!LReg args;
	foreach (it ; semFrame.vars) {
	    auto ret = new LReg (it.info.id, it.info.type.size);
	    args.insertBack (ret);
	    auto compS = it.info.type.ParamOp ();
	    if (compS) {
		LInstList list;
		if (compS.leftTreatment) {
		    list = compS.leftTreatment (it.info.type, it, null);
		} else list = new LInstList (ret);
		entry.insts += compS.lintInst (list);
	    }
	}
	
	visit (entry, end, retReg, semFrame.block);
 
	foreach (it ; semFrame.dest) {
	    end.insts += it.destruct ();
	}
	
	auto fr = new LFrame (semFrame.name, entry, end, retReg, args);
	fr.file = semFrame.file;
	fr.lastId = LReg.lastId;
	return fr;
    }

    private void visit (ref LLabel begin, ref LLabel end, ref LReg retReg, Block block) {
	if (begin.insts is null) begin.insts = new LInstList ();
	if (end.insts is null) end.insts = new LInstList ();
	foreach (it ; block.insts) {
	    visitInstruction (begin, end, retReg, it);
	}
	
	foreach (it ; block.dest) {
	    begin.insts += it.destruct ();
	}
	
	begin.insts.clean ();	
	end.insts.clean ();
    }

    private LInstList visitBlock (ref LLabel end, ref LReg retReg, Block block) {
	auto inst = new LInstList;
	foreach (it ; block.insts) {
	    visitInstruction (inst, end, retReg, it);
	}
	foreach (it ; block.dest) {
	    inst += it.destruct ();
	}
	
	inst.clean ();	
	end.insts.clean ();
	return inst;
    }
    
    private void visitInstruction (ref LInstList begin, ref LLabel end, ref LReg retReg, Instruction elem) {
	if (auto exp = cast(Expression)elem) begin += visitExpression (exp);
	else if (auto decl = cast(VarDecl)elem) begin += visitVarDecl (decl);
	else if (auto ret = cast(Return)elem) begin += visitReturn (end, retReg, ret);
	else if (auto _if = cast(If)elem) begin += visitIf (end, retReg, _if);
	else if (auto _while = cast(While) elem) begin += visitWhile (end, retReg, _while);
	else if (auto _block = cast(Block) elem) begin += visitBlock (end, retReg, _block);
	else if (auto _break = cast (Break) elem) begin += visitBreak (_break);
	else assert (false, "TODO visitInstruction ! " ~ elem.toString);
    }
    
    private void visitInstruction (ref LLabel begin, ref LLabel end, ref LReg retReg, Instruction elem) {
	if (auto exp = cast(Expression)elem) begin.insts += visitExpression (exp);
	else if (auto decl = cast(VarDecl)elem) begin.insts += visitVarDecl (decl);
	else if (auto ret = cast(Return)elem) begin.insts += visitReturn (end, retReg, ret);
	else if (auto _if = cast(If)elem) begin.insts += visitIf (end, retReg, _if);
	else if (auto _while = cast(While)elem) begin.insts += visitWhile (end, retReg, _while);
	else if (auto _block = cast(Block) elem) begin.insts += visitBlock (end, retReg, _block);
	else if (auto _break = cast (Break) elem) begin.insts += visitBreak (_break);
	else assert (false, "TODO visitInstruction ! " ~ elem.toString);
    }

    private LInstList visitIf (ref LLabel end, ref LReg retReg, If _if) {
	auto insts = new LInstList;
	insts += new LLocus (_if.token.locus);
	LLabel faux = new LLabel ();
	LLabel vrai = new LLabel ();
	LLabel fin = new LLabel ();
	LInstList left;
	if (_if.info !is _if.test.info.type) {
	    if (_if.info.leftTreatment !is null )
		left = _if.info.leftTreatment (_if.info, _if.test, null);
	    else left = visitExpression (_if.test);
	    auto tlist = _if.info.lintInst (left);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	} else {
	    auto tlist = visitExpression (_if.test);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	}

	vrai.insts = visitBlock (end, retReg, _if.block);
	vrai.insts += new LGoto (fin);	
	if (_if.else_ !is null) {
	    faux.insts = visitElse (end, fin, retReg, _if.else_);
	} else faux.insts = new LInstList (new LGoto (fin));
	
	vrai.insts.clean ();
	faux.insts.clean ();
	insts += faux;
	insts += vrai;
	insts += fin;
	return insts;
    }

    private LInstList visitWhile (ref LLabel end, ref LReg retReg, While _while) {
	auto inst = new LInstList;
	inst += new LLocus (_while.token.locus);
	LLabel faux = new LLabel (), vrai = new LLabel, debut = new LLabel;
	this._endLabels [_while.block] = faux;
	LInstList left;
	inst += debut;
	if (_while.info !is _while.test.info.type) {
	    if (_while.info.leftTreatment !is null)
		left = _while.info.leftTreatment (_while.info, _while.test, null);
	    else left = visitExpression (_while.test);
	    auto tlist = _while.info.lintInst (left);
	    inst += tlist;	    
	    inst += new LJump (tlist.getFirst (), vrai);
	    inst += new LGoto (faux);
	} else {
	    auto tlist = visitExpression (_while.test);
	    inst += tlist;
	    inst += new LJump (tlist.getFirst, vrai);
	    inst += new LGoto (faux);
	}
	vrai.insts = visitBlock (end, retReg, _while.block);
	vrai.insts += new LGoto (debut);
	vrai.insts.clean ();
	inst += vrai;
	inst += faux;
	this._endLabels.remove (_while);
	return inst;
    }
    

    private LInstList visitElse (ref LLabel end, ref LLabel fin, ref LReg retReg, Else _else) {	
	if (cast(ElseIf) _else is null) {
	    auto inst =  visitBlock (end, retReg, _else.block);
	    inst += new LGoto (fin);
	    return inst;
	}
	auto elseif = cast(ElseIf)_else;
	auto insts = new LInstList;
	insts += new LLocus (_else.token.locus);
	LLabel faux = new LLabel, vrai = new LLabel;
	LInstList left;
	if (elseif.info !is elseif.test.info.type) {
	    if (elseif.info.leftTreatment !is null )
		left = elseif.info.leftTreatment (elseif.info, elseif.test, null);
	    else left = visitExpression (elseif.test);
	    auto tlist = elseif.info.lintInst (left);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	} else {
	    auto tlist = visitExpression (elseif.test);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	}

	vrai.insts = visitBlock (end, retReg, elseif.block);
	vrai.insts += new LGoto (fin);
	if (elseif.else_ !is null) {
	    faux.insts = visitElse (end, fin, retReg, elseif.else_);
	} else faux.insts = new LInstList (new LGoto(fin));
	vrai.insts.clean ();
	faux.insts.clean ();
	insts += faux;
	insts += vrai;
	return insts;
    }
    
    private LInstList visitBreak (Break elem) {
	auto list = new LInstList;
	list += new LLocus (elem.token.locus);
	auto current = elem.father;
	ulong nb = 0;
	while (current !is null && nb < elem.nbBlock) {
	    foreach (it ; current.dest) {
		list += it.destruct ();
	    }
	    nb ++;
	    if (nb < elem.nbBlock)
		current = current.father;
	}
	elem.father.dest.clear ();
	auto endLabel = this._endLabels [current];
	list += new LGoto (endLabel);
	return list;
    }

    private LInstList visitReturn (ref LLabel end, ref LReg retReg, Return ret) {
	LInstList list = new LInstList ();
	list += new LLocus (ret.token.locus);
	if (ret.elem !is null) {
	    LInstList rlist;
	    if (ret.instComp !is null) {
		if (ret.instComp.leftTreatment)
		    rlist = ret.instComp.leftTreatment (ret.elem.info.type, ret.elem, null);
		else rlist = visitExpression (ret.elem);
		list += ret.instComp.lintInst (rlist);
	    } else {
		rlist = visitExpression (ret.elem);
		list += rlist;
	    }
	    list += (new LWrite (retReg,  rlist.getFirst ()));	    
	}
	
	foreach (it ; ret.father.dest) {
	    list += it.destruct ();
	}
	
	ret.father.dest.clear ();	
	list += new LGoto (end);
	return list;
    }

    static LInstList visitExpressionOutSide (Expression elem) {
	auto visitor = new LVisitor ();
	return visitor.visitExpression (elem);
    }
    
    private LInstList visitExpression (Expression elem) {
	if (auto bin = cast(Binary) elem) return visitBinary (bin);
	if (auto var = cast(Var)elem) return visitVar (var);
	if (auto _int = cast(Int)elem) return visitInt (_int);
	if (auto _float = cast(Float)elem) return visitFloat (_float);
	if (auto _char = cast(Char) elem) return visitChar (_char);
	if (auto _sys = cast (System)elem) return visitSystem (_sys);
	if (auto _par = cast (Par) elem) return visitPar (_par);
	if (auto _cast = cast(Cast) elem) return visitCast (_cast);
	if (auto _str = cast(String) elem) return visitStr (_str);
	if (auto _access = cast (Access) elem) return visitAccess (_access);
	if (auto _dot = cast (Dot) elem) return visitDot (_dot);
	if (auto _bool = cast (Bool) elem) return visitBool (_bool);
	if (auto _unop = cast (BefUnary) elem) return visitBefUnary (_unop);
	if (auto _null = cast (Null) elem) return visitNull (_null);
	if (auto _carray = cast (ConstArray) elem) return visitConstArray (_carray);
	if (auto _fptr = cast (FuncPtr) elem) return visitFuncPtr (_fptr);
	if (auto _long = cast (Long) elem) return visitLong (_long);
	assert (false, "TODO, visitExpression ! " ~ elem.toString);
    }

    private LInstList visitFuncPtr (FuncPtr fptr) {
	auto inst = new LInstList;
	if (fptr.expr is null) {
	    inst += new LConstQWord (0);
	} else {
	    auto ptr = cast (PtrFuncInfo) fptr.info.type;
	    inst += new LConstFunc (ptr.score.name);
	}
	return inst;
    }
    
    private LInstList visitConstArray (ConstArray carray) {
	auto type = cast (ArrayInfo) carray.info.type;
	Array!LExp params;
	params.insertBack (new LConstQWord (carray.params.length, type.content.size));
	params.insertBack (new LConstQWord (1, type.content.size));
	
	auto inst = new LInstList;
	auto aux = new LReg (carray.info.id, type.size);
	if (!(cast (ArrayInfo)carray.info.type).content.isDestructible) {	    
	    auto exist = (ArrayUtils.__CstName__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createCstArray ();
	    inst += new LWrite (aux, new LCall (ArrayUtils.__CstName__, params, LSize.LONG));
	} else {
	    auto exist = (ArrayUtils.__CstNameObj__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createCstArray (ArrayUtils.__DstArray__);
	    exist = (ArrayUtils.__DstArray__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createDstArray ();
	    inst += new LWrite (aux, new LCall (ArrayUtils.__CstNameObj__, params, LSize.LONG));
	}
	
	foreach (it ; 0 .. carray.params.length) {
	    auto cster = carray.casters [it];
	    LInstList ret;
	    if (cster.lintInstS is null) ret = visitExpression (carray.params [it]);
	    else ret = cster.lintInst (visitExpression (carray.params [it]));
	    auto regRead = new LRegRead (aux,
					 new LBinop (new LConstDWord (it, type.content.size), new LConstDWord (3, LSize.LONG), Tokens.PLUS),
					 type.content.size);
	    					 
	    inst += cster.lintInst (new LInstList (regRead), ret);
	}
	inst += aux;
	return inst;
    }
    
    private LInstList visitNull (Null _null) {
	return new LInstList (new LConstQWord (0));
    }

    private LInstList visitBefUnary (BefUnary unary) {
	return unary.info.type.lintInst (visitExpression (unary.elem));
    }
    
    private LInstList visitStr (String elem) {
	Array!LExp exps;
	exps.insertBack (new LConstQWord (elem.content.length));
	exps.insertBack (new LConstString (elem.content));
	auto inst = new LInstList;
	auto it = (StringUtils.__CstName__ in LFrame.preCompiled);
	if (it is null) {
	    StringUtils.createCstString ();
	}
	if (elem.info.type.isDestructible) {
	    auto aux = new LReg (elem.info.id, elem.info.type.size);
	    inst += new LWrite (aux, new LCall (StringUtils.__CstName__, exps, LSize.LONG));
	    inst += aux;
	} else {
	    inst += new LCall (StringUtils.__CstName__, exps, LSize.LONG);
	}

	return inst;
    }
    
    private LInstList visitVar (Var elem) {
	return new LInstList (new LReg (elem.info.id, elem.info.type.size));
    }

    private LInstList visitBool (Bool elem) {
	if (elem.value) return new LInstList (new LConstByte (1));
	else return new LInstList (new LConstByte (0));
    }
    
    private LInstList visitChar (Char elem) {
	return new LInstList (new LConstByte (to!ubyte (elem.code)));
    }
    
    private LInstList visitInt (Int elem) {
	return new LInstList (new LConstDWord (to!int (elem.token.str)));
    }

    private LInstList visitLong (Long elem) {
	return new LInstList (new LConstQWord (to!long (elem.token.str [0 .. $ - 1])));// on enleve le 'l'
    }
    
    private LInstList visitFloat (Float elem) {
	return new LInstList (new LConstDouble (to!double (elem.totale)));
    }

    private LInstList visitSystem (System sys) {
	Array!LExp exprs;
	LInstList list = new LInstList;
	foreach (it ; sys.params) {
	    auto elist = visitExpression (it);
	    exprs.insertBack (elist.getFirst ());
	    list += elist;
	}
	list += new LSysCall (sys.token.str, exprs);
	return list;
    }

    private LInstList visitPar (Par par) {
	Array!LExp exprs;
	Array!LInstList rights;
	LInstList list = new LInstList;
	LExp call;

	if (par.info.type.lintInstMult) {
	    foreach (it ; 0 .. par.params.length) {
		Expression exp = par.params [it];
		LInstList elist;
		if (par.score.treat [it] && par.score.treat [it].lintInstS) 
		    elist = par.score.treat [it].lintInst (visitExpression (exp));
		else
		elist = visitExpression (exp);
		rights.insertBack (elist);
	    }
	    
	    LInstList left;
	    if (par.info.type.leftTreatment) left = par.info.type.leftTreatment (par.info.type, par.left, par.paramList);
	    else left = visitExpression (par.left);
	    list = par.info.type.lintInst (left, rights);
	    call = list.getFirst ();
	} else {
	    foreach (it ; 0 .. par.params.length) {
		Expression exp = par.params [it];
		LInstList elist;
		if (par.score.treat [it] && par.score.treat [it].lintInstS) 
		    elist = par.score.treat [it].lintInst (visitExpression (exp));
		else
		elist = visitExpression (exp);
		exprs.insertBack (elist.getFirst ());
		list += elist;
	    }
	    
	    if (par.score.dyn) {
		auto left = visitExpression (par.left);
		list += left;
		call = new LCall (left.getFirst (), exprs, par.score.ret.size);
	    } else {		
		call = new LCall (par.score.name, exprs, par.score.ret.size);
	    }
	}
	
	if (cast (VoidInfo) par.score.ret is null) {
	    auto reg = new LReg (par.info.id, par.score.ret.size);	    
	    list += new LWrite (reg, call);
	} else 	list += call;
	return list;	
    }

    private LInstList visitAccess (Access access) {
	Array!LInstList exprs;
	auto inst = new LInstList;
	foreach (it ; 0 .. access.params.length) {
	    exprs.insertBack (visitExpression (access.params [it]));
	}
	auto type = access.info.type;
	LInstList left;
	if (access.info.type.leftTreatment)
	    left = access.info.type.leftTreatment (access.info.type, access.left, null);
	else left = visitExpression (access.left);
	inst += type.lintInst (left, exprs);
	return inst;
    }
    
    private LInstList visitDot (Dot dot) {
	LInstList left;
	if (dot.info.type.leftTreatment) {
	    left = dot.info.type.leftTreatment (dot.info.type, dot.left, null);
	} else left = visitExpression (dot.left);
	auto inst = dot.info.type.lintInst (LInstList.init, left);
	if (dot.info.isDestructible) {
	    auto sym = new LReg (dot.info.id, dot.info.type.size);
	    auto last = inst.getFirst ();
	    inst += new LWrite (sym, last);
	}
	return inst;
    }
    
    private LInstList visitCast (Cast elem) {
	auto left = elem.info.type;
	if (left is elem.expr.info.type) {
	    return visitExpression (elem.expr);
	} else {
	    return left.lintInst (visitExpression (elem.expr));
	}
    }
    
    private LInstList visitVarDecl (VarDecl elem) {
	LInstList inst = new LInstList;
	foreach (it ; elem.insts) {
	    inst += visitExpression (it);
	}
	return inst;
    }

    private LInstList visitBinary (Binary bin) {
	LInstList left, right;
	if (bin.info.type.leftTreatment !is null) 
	    left = bin.info.type.leftTreatment (bin.info.type, bin.left, bin.right);
	else left = visitExpression (bin.left);
	
	if (bin.info.type.rightTreatment !is null)
	    right = bin.info.type.rightTreatment (bin.info.type, bin.left, bin.right);
	else right = visitExpression (bin.right);
	    
	auto ret = bin.info.type.lintInst (left, right);
	ret.back.locus = bin.token.locus;
	if (bin.info.isDestructible && bin.info.id != 0) {
	    auto last = ret.getFirst ();
	    auto reg = new LReg (bin.info.id, bin.info.type.size);
	    ret += new LWrite (reg, last);
	}
	auto inst = new LInstList (new LLocus (bin.token.locus));
	return inst + ret;
    }

}


