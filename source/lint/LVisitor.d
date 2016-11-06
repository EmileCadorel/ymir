module lint.LVisitor;
import semantic.pack.FrameTable, semantic.pack.Frame;
import lint.LFrame, lint.LInstList, lint.LLabel, lint.LReg;
import semantic.types.VoidInfo;
import lint.LConst, lint.LRegRead;
import semantic.pack.Symbol, lint.LGoto, lint.LWrite;
import ast.all, std.container, std.conv;

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
	LReg.lastId = Symbol.lastId;
	if (semFrame.type !is null && cast(VoidInfo)semFrame.type.type is null) {
	    retReg = new LReg (semFrame.type.type.size);
	}

	Array!LReg args;
	foreach (it ; semFrame.vars) {
	    args.insertBack (new LReg (it.info.id, it.info.type.size));
	}

	visit (entry, end, retReg, semFrame.block);
	return new LFrame (semFrame.name, entry, end, retReg, args);
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
    
    private void visitInstruction (ref LLabel begin, ref LLabel end, ref LReg retReg, Instruction elem) {
	if (auto exp = cast(Expression)elem) begin.insts += visitExpression (exp);
	else if (auto decl = cast(VarDecl)elem) begin.insts += visitVarDecl (decl);
	else if (auto ret = cast(Return)elem) begin.insts += visitReturn (end, retReg, ret);
	else assert (false, "TODO visitInstruction ! " ~ elem.toString);
    }

    private LInstList visitReturn (ref LLabel end, ref LReg retReg, Return ret) {
	LInstList list = new LInstList ();
	if (ret.elem !is null) {
	    auto rlist = visitExpression (ret.elem);
	    list += rlist;
	    list += (new LWrite (new LRegRead (retReg),  rlist.getFirst ()));
	}
	list += new LGoto (end);
	return list;
    }
    
    private LInstList visitExpression (Expression elem) {
	if (auto bin = cast(Binary) elem) return visitBinary (bin);
	if (auto var = cast(Var)elem) return visitVar (var);
	else if (auto _int = cast(Int)elem) return visitInt (_int);
	else if (auto _float = cast(Float)elem) return visitFloat (_float);
	else assert (false, "TODO, visitExpression ! " ~ elem.toString);
    }

    private LInstList visitVar (Var elem) {
	return new LInstList (new LRegRead (new LReg (elem.info.id, elem.info.type.size)));
    }

    private LInstList visitInt (Int elem) {
	return new LInstList (new LConstDWord (to!int (elem.token.str)));
    }
    
    private LInstList visitFloat (Float elem) {
	return new LInstList (new LConstFloat (to!float (elem.totale)));
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


