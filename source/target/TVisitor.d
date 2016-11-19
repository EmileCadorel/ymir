module target.TVisitor;
public import lint.LFrame, lint.LLabel;
public import lint.LReg;
public import lint.LInst, lint.LWrite, lint.LExp;
public import lint.LRegRead, lint.LData, lint.LConst;
public import lint.LBinop, lint.LGoto;
public import lint.LSysCall, lint.LJump;
public import lint.LCall, lint.LInstList;
public import target.TInstList, target.TFrame, target.TInstPaire;
public import target.TReg, target.TLabel, target.TExp;
import std.container;

abstract class TVisitor {

    public final Array!TFrame target (Array!LFrame frames) {
	Array!TFrame ret;
	foreach (it ; frames) {
	    ret.insertBack (this.visit (it));
	}
	return ret;
    }
    
    abstract protected TFrame visit (LFrame frame);
       
    abstract protected TLabel visit (LLabel label);

    final protected TInstList visitInstructions (LInstList inst) {
	if (inst is null) return new TInstList;
	auto ret = new TInstList;
	foreach (it ; inst.insts) {
	    ret += visit (it);
	}
	return ret;
    }

    final protected TInstList visit (LInst inst) {
	if (auto write = cast (LWrite) (inst)) return visitWrite (write);
	else if (auto bin = cast (LBinop) (inst)) return visitBinop (bin).what;
	else if (auto go = cast (LGoto) (inst)) return visitGoto (go);
	else if (auto sys = cast (LSysCall) inst) return visitSys (sys);
	else if (auto jump = cast (LJump) inst) return visitJump (jump);
	else if (auto lbl = cast (LLabel) inst) return new TInstList (visit (lbl));
	else if (auto call = cast (LCall) inst) return visitCall (call).what;
	assert (false, "TODO, visit (" ~ inst.toString () ~ ")");
    }

    abstract protected TInstList visitJump (LJump jump);
    
    abstract protected TInstList visitSys (LSysCall sys);
        
    abstract protected TInstList visitGoto (LGoto elem);
    
    abstract protected TInstList visitWrite (LWrite write);

    final protected TInstPaire visitExpression (LExp elem) {
	if (auto reg = cast(LRegRead) elem) return visitRegRead (reg);
	else if (auto reg = cast(LReg) elem) return visit (reg);
	else if (auto co = cast (LConst) elem) return visitConst (co);
	else if (auto bin = cast(LBinopSized) elem) return visitBinopSized (bin);
	else if (auto bin = cast (LBinop) elem) return visitBinop (bin);
	else if (auto call = cast (LCall) elem) return visitCall (call);
	assert (false, "TODO, visitExpression (LExp)");
    }

    abstract protected TInstPaire visitRegRead (LRegRead reg);
    
    abstract protected TReg visitReg (LReg reg);
    
    abstract protected TInstPaire visitBinop (LBinop bin);
    
    abstract protected TInstPaire visitBinopSized (LBinopSized bin);
    
    abstract protected  TInstPaire visitCall (LCall call);
    
    final protected TInstPaire visitConst (LConst co) {
	if (auto by = cast(LConstByte) (co))
	    return visitConstByte (by);
	else if (auto w = cast (LConstWord) (co)) 
	    return visitConstWord (w);
	else if (auto dw = cast(LConstDWord) (co))
	    return visitConstDWord (dw);
	else if (auto qw = cast(LConstQWord) (co))
	    return visitConstQWord (qw);
	else if (auto lf = cast(LConstFloat) (co))
	    return visitConstFloat (lf);
	else if (auto ld = cast(LConstDouble) (co))
	    return visitConstDouble (ld);
	assert (false, "TODO, visitConst (LConst co)");
    }

    abstract protected TInstPaire visitConstByte (LConstByte);

    abstract protected TInstPaire visitConstWord (LConstWord);

    abstract protected TInstPaire visitConstDWord (LConstDWord);

    abstract protected TInstPaire visitConstQWord (LConstQWord);

    abstract protected TInstPaire visitConstFloat (LConstFloat);

    abstract protected TInstPaire visitConstDouble (LConstDouble);
    
    abstract protected TInstPaire visit (LReg reg);    
    
}
