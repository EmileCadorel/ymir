module ymir.target.TVisitor;
import ymir.lint._;
import ymir.target._;

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
	else if (auto _loc = cast (LLocus) inst) return visitLocus (_loc);
	else if (auto _unop = cast (LUnop) inst) return visitUnop (_unop).what;
	else if (auto _res = cast (LReserve) inst) return visitReserve (_res).what;
	assert (false, "TODO, visit (" ~ inst.toString () ~ ")");	
    }

    abstract protected TInstList visitJump (LJump);
    
    abstract protected TInstList visitSys (LSysCall);
        
    abstract protected TInstList visitGoto (LGoto);
    
    abstract protected TInstList visitWrite (LWrite);

    protected TInstList visitLocus (LLocus) {
	assert (false);
    }

    final protected TInstPaire visitExpression (LExp elem) {
	if (auto reg = cast(LRegRead) elem) return visitRegRead (reg);
	if (auto reg = cast(LReg) elem) return visit (reg);
	if (auto co = cast (LConst) elem) return visitConst (co);
	if (auto bin = cast (LBinop) elem) return visitBinop (bin);
	if (auto call = cast (LCall) elem) return visitCall (call);
	if (auto _cast = cast(LCast) elem) return visitCast (_cast);
	if (auto _unop = cast (LUnop) elem) return visitUnop (_unop);
	if (auto _addr = cast (LAddr) elem) return visitAddr (_addr);
	if (auto _res = cast (LReserve) elem) return visitReserve (_res);
	assert (false, "TODO, visitExpression " ~ typeid (elem).toString);
    }

    final protected TInstPaire visitExpression (LExp elem, TExp where) {
	if (auto reg = cast(LRegRead) elem) return visitRegRead (reg, where);
	if (auto reg = cast(LReg) elem) return visit (reg, where);
	if (auto co = cast (LConst) elem) return visitConst (co, where);
	if (auto bin = cast (LBinop) elem) return visitBinop (bin, where);
	if (auto call = cast (LCall) elem) return visitCall (call, where);
	if (auto _cast = cast(LCast) elem) return visitCast (_cast, where);
	if (auto _unop = cast (LUnop) elem) return visitUnop (_unop, where);
	if (auto _addr = cast (LAddr) elem) return visitAddr (_addr, where);
	if (auto _res = cast (LReserve) elem) return visitReserve (_res, where);
	assert (false, "TODO, visitExpression " ~ typeid (elem).toString);
    }
    
    abstract protected TInstPaire visitRegRead (LRegRead);
    
    abstract protected TReg visitReg (LReg);
    
    abstract protected TInstPaire visitBinop (LBinop);
    
    abstract protected  TInstPaire visitCall (LCall);

    abstract protected TInstPaire visitCast (LCast);

    abstract protected TInstPaire visitUnop (LUnop);

    abstract protected TInstPaire visitAddr (LAddr);

    abstract protected TInstPaire visitReserve (LReserve);

    protected TInstPaire visitRegRead (LRegRead, TExp) {
	assert (false);
    }
    
    protected TReg visitReg (LReg, TExp) {
	assert (false);
    }
    
    protected TInstPaire visitBinop (LBinop, TExp) {
	assert (false);
    }
    
    protected  TInstPaire visitCall (LCall, TExp) {
	assert (false);
    }

    protected TInstPaire visitCast (LCast, TExp) {
	assert (false);
    }

    protected TInstPaire visitUnop (LUnop, TExp) {
	assert (false);
    }

    protected TInstPaire visitAddr (LAddr, TExp) {
	assert (false);
    }

    protected TInstPaire visitReserve (LReserve, TExp) {
	assert (false);
    }
    
    final protected TInstPaire visitConst (LConst co) {
	if (auto by = cast(LConstDecimal) (co))
	    return visitConstDecimal (by);
	else if (auto by = cast(LConstUDecimal) (co))
	    return visitConstUDecimal (by);
	else if (auto lf = cast(LConstFloat) (co))
	    return visitConstFloat (lf);
	else if (auto ld = cast(LConstDouble) (co))
	    return visitConstDouble (ld);
	else if (auto cstr = cast (LConstString) (co))
	    return visitConstString (cstr);
	else if (auto cfc = cast (LConstFunc) co)
	    return visitConstFunc (cfc);
	assert (false, "TODO, visitConst (LConst co)");
    }
    
    abstract protected TInstPaire visitConstDecimal (LConstDecimal);

    abstract protected TInstPaire visitConstUDecimal (LConstUDecimal);
    
    abstract protected TInstPaire visitConstFloat (LConstFloat);

    abstract protected TInstPaire visitConstDouble (LConstDouble);

    abstract protected TInstPaire visitConstString (LConstString);

    abstract protected TInstPaire visitConstFunc (LConstFunc);
    
    abstract protected TInstPaire visit (LReg reg);    

    final protected TInstPaire visitConst (LConst co, TExp where) {
	if (auto by = cast(LConstDecimal) (co))
	    return visitConstDecimal (by, where);
	else if (auto by = cast(LConstUDecimal) (co))
	    return visitConstUDecimal (by, where);
	else if (auto lf = cast(LConstFloat) (co))
	    return visitConstFloat (lf, where);
	else if (auto ld = cast(LConstDouble) (co))
	    return visitConstDouble (ld, where);
	else if (auto cstr = cast (LConstString) (co))
	    return visitConstString (cstr, where);
	else if (auto cfc = cast (LConstFunc) co)
	    return visitConstFunc (cfc, where);
	assert (false, "TODO, visitConst (LConst co)");
    }
    
    protected TInstPaire visitConstDecimal (LConstDecimal, TExp) {
	assert (false);
    }

    protected TInstPaire visitConstUDecimal (LConstUDecimal, TExp) {
	assert (false);
    }

    protected TInstPaire visitConstFloat (LConstFloat, TExp) {
	assert (false);
    }

    protected TInstPaire visitConstDouble (LConstDouble, TExp) {
	assert (false);
    }

    protected TInstPaire visitConstString (LConstString, TExp) {
	assert (false);
    }

    protected TInstPaire visitConstFunc (LConstFunc, TExp) {
	assert (false);
    }
        
    protected TInstPaire visit (LReg reg, TExp) {
	assert (false);
    }
    
}
