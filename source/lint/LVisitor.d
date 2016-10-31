module lint.LVisitor;
import semantic.pack.FrameTable, semantic.pack.Frame;
import lint.LFrame, lint.LInstList, lint.LLabel, lint.LReg;
import semantic.types.VoidInfo;
import lint.LConst, lint.LRegRead;
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
	if (semFrame.type !is null && cast(VoidInfo)semFrame.type.type is null) {
	    retReg = new LReg (semFrame.type.type.size);
	}

	Array!LReg args;
	foreach (it ; semFrame.vars) {
	    args.insertBack (new LReg (it.info.id, it.info.type.size));
	}
	
	return new LFrame (semFrame.name, entry, end, retReg, args, visit(semFrame.block));
    }

    private LInstList visit (Block block) {
	LInstList inst = new LInstList;
	foreach (it ; block.insts) {
	    inst += visitInstruction (it);
	}
	inst.clean ();
	return inst;
    }

    private LInstList visitInstruction (Instruction elem) {
	if (auto exp = cast(Expression)elem) return visitExpression (exp);
	else if (auto decl = cast(VarDecl)elem) return visitVarDecl (decl);
	return new LInstList ();
    }
    
    private LInstList visitExpression (Expression elem) {
	if (auto bin = cast(Binary) elem) return visitBinary (bin);
	if (auto var = cast(Var)elem) return visitVar (var);
	else if (auto _int = cast(Int)elem) return visitInt (_int);
	return new LInstList ();
    }

    private LInstList visitVar (Var elem) {
	return new LInstList (new LRegRead (new LReg (elem.info.id, elem.info.type.size)));
    }

    private LInstList visitInt (Int elem) {
	return new LInstList (new LConstDWord (to!int (elem.token.str)));
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


