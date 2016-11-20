module lint.LVisitor;
import semantic.pack.FrameTable, semantic.pack.Frame;
import lint.LFrame, lint.LInstList, lint.LLabel, lint.LReg;
import semantic.types.VoidInfo;
import lint.LConst, lint.LRegRead, lint.LJump;
import semantic.pack.Symbol, lint.LGoto, lint.LWrite, lint.LCall;
import ast.all, std.container, std.conv, lint.LExp, lint.LSysCall;

class LVisitor {
    
    Array!LFrame visit () {
	Array!LFrame frames;
	foreach (it ; FrameTable.instance.finals) {
	    frames.insertBack (this.visit (it));
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
	
	Array!LReg args;
	foreach (it ; semFrame.vars) {
	    args.insertBack (new LReg (it.info.id, it.info.type.size));
	}

	visit (entry, end, retReg, semFrame.block);
	auto fr = new LFrame (semFrame.name, entry, end, retReg, args);
	fr.lastId = LReg.lastId;
	return fr;
    }

    private void visit (ref LLabel begin, ref LLabel end, ref LReg retReg, Block block) {
	begin.insts = new LInstList ();
	end.insts = new LInstList ();
	foreach (it ; block.insts) {
	    visitInstruction (begin, end, retReg, it);
	}
	begin.insts.clean ();	
	end.insts.clean ();
    }

    private LInstList visitBlock (ref LLabel end, ref LReg retReg, Block block) {
	auto inst = new LInstList;
	foreach (it ; block.insts) {
	    visitInstruction (inst, end, retReg, it);
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
	else assert (false, "TODO visitInstruction ! " ~ elem.toString);
    }
    
    private void visitInstruction (ref LLabel begin, ref LLabel end, ref LReg retReg, Instruction elem) {
	if (auto exp = cast(Expression)elem) begin.insts += visitExpression (exp);
	else if (auto decl = cast(VarDecl)elem) begin.insts += visitVarDecl (decl);
	else if (auto ret = cast(Return)elem) begin.insts += visitReturn (end, retReg, ret);
	else if (auto _if = cast(If)elem) begin.insts += visitIf (end, retReg, _if);
	else if (auto _while = cast(While)elem) begin.insts += visitWhile (end, retReg, _while);
	else if (auto _block = cast(Block) elem) begin.insts += visitBlock (end, retReg, _block);
	else assert (false, "TODO visitInstruction ! " ~ elem.toString);
    }

    private LInstList visitIf (ref LLabel end, ref LReg retReg, If _if) {
	auto insts = new LInstList;
	LLabel faux = new LLabel ();
	LLabel vrai = new LLabel ();
	LLabel fin = new LLabel ();
	Expression left = _if.test;
	if (_if.info !is _if.test.info.type) {
	    if (_if.info.leftTreatment !is null )
		left = _if.info.leftTreatment (left);
	    auto tlist = _if.info.lintInst (visitExpression (left));
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	} else {
	    auto tlist = visitExpression (left);
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
	LLabel faux = new LLabel (), vrai = new LLabel, debut = new LLabel;
	auto left = _while.test;
	inst += debut;
	if (_while.info !is _while.test.info.type) {
	    if (_while.info.leftTreatment !is null)
		left = _while.info.leftTreatment (left);
	    auto tlist = _while.info.lintInst (visitExpression (left));
	    inst += tlist;	    
	    inst += new LJump (tlist.getFirst (), vrai);
	    inst += new LGoto (faux);
	} else {
	    auto tlist = visitExpression (left);
	    inst += tlist;
	    inst += new LJump (tlist.getFirst, vrai);
	    inst += new LGoto (faux);
	}
	vrai.insts = visitBlock (end, retReg, _while.block);
	vrai.insts += new LGoto (debut);
	vrai.insts.clean ();
	inst += vrai;
	inst += faux;
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
	LLabel faux = new LLabel, vrai = new LLabel;
	Expression left = elseif.test;
	if (elseif.info !is elseif.test.info.type) {
	    if (elseif.info.leftTreatment !is null )
		left = elseif.info.leftTreatment (left);
	    auto tlist = elseif.info.lintInst (visitExpression (left));
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	} else {
	    auto tlist = visitExpression (left);
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
    
    private LInstList visitReturn (ref LLabel end, ref LReg retReg, Return ret) {
	LInstList list = new LInstList ();
	if (ret.elem !is null) {
	    auto rlist = visitExpression (ret.elem);
	    list += rlist;
	    list += (new LWrite (retReg,  rlist.getFirst ()));
	}
	list += new LGoto (end);
	return list;
    }
    
    private LInstList visitExpression (Expression elem) {
	if (auto bin = cast(Binary) elem) return visitBinary (bin);
	if (auto var = cast(Var)elem) return visitVar (var);
	else if (auto _int = cast(Int)elem) return visitInt (_int);
	else if (auto _float = cast(Float)elem) return visitFloat (_float);
	else if (auto _char = cast(Char) elem) return visitChar (_char);
	else if (auto _sys = cast (System)elem) return visitSystem (_sys);
	else if (auto _par = cast (Par) elem) return visitPar (_par);
	else if (auto _cast = cast(Cast) elem) return visitCast (_cast);
	else if (auto _str = cast(String) elem) return visitStr (_str);
	else if (auto _access = cast (Access) elem) return visitAccess (_access);
	else assert (false, "TODO, visitExpression ! " ~ elem.toString);
    }

    private LInstList visitStr (String elem) {
	return new LInstList (new LConstString (elem.content));
    }
    
    private LInstList visitVar (Var elem) {
	return new LInstList (new LReg (elem.info.id, elem.info.type.size));
    }

    private LInstList visitChar (Char elem) {
	return new LInstList (new LConstByte (to!byte (elem.code)));
    }
    
    private LInstList visitInt (Int elem) {
	return new LInstList (new LConstQWord (to!int (elem.token.str)));
    }
    
    private LInstList visitFloat (Float elem) {
	return new LInstList (new LConstFloat (to!float (elem.totale)));
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
	LInstList list = new LInstList;
	foreach (it ; 0 .. par.params.length) {
	    Expression exp = par.params [it];
	    if (par.score.treat [it] !is null) exp = par.score.treat [it] (exp);
	    auto elist = visitExpression (exp);
	    exprs.insertBack (elist.getFirst ());
	    list += elist;
	}
	
	auto call = new LCall (par.score.name, exprs);
	if (cast (VoidInfo) par.score.ret is null) {
	    auto res = new LReg (8);
	    list += new LWrite (res, call);
	}
	else 
	    list += call;
	
	return list;
    }

    private LInstList visitAccess (Access access) {
	Array!LInstList exprs;
	auto inst = new LInstList;
	foreach (it ; 0 .. access.params.length) {
	    exprs.insertBack (visitExpression (access.params [it]));
	}
	auto type = access.info.type;
	inst += type.lintInst (visitExpression (access.left), exprs);
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
	Expression left = bin.left, right = bin.right;
	if (bin.info.type.leftTreatment !is null) 
	    left = bin.info.type.leftTreatment (left);
	if (bin.info.type.rightTreatment !is null)
	    right = bin.info.type.rightTreatment (right);
	return bin.info.type.lintInst (visitExpression (left), visitExpression (right));
    }

}


