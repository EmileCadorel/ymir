module target.TVisitor;
import lint.LFrame, target.TFrame, target.TLabel, lint.LLabel;
import lint.LReg, target.TReg, target.TInstList, lint.LInstList;
import lint.LInst, lint.LWrite, target.TInstPaire, lint.LExp, target.TWrite;
import lint.LRegRead, target.TRegRead, lint.LData, lint.LConst;
import target.TConst;
import std.container;

class TVisitor {

    Array!TFrame visit (Array!LFrame frames) {
	Array!TFrame ret;
	foreach (it ; frames) {
	    ret.insertBack (this.visit (it));
	}
	return ret;
    }
    
    private TFrame visit (LFrame frame) {
	TFrame retour = new TFrame (frame.number, frame.name);
	retour.entryLbl = visit (frame.entryLbl);
	retour.returnLbl = visit (frame.returnLbl);
	foreach (it ; frame.args) {
	    retour.paramRegs.insertBack (visit (it));
	}
	retour.returnReg = visit (frame.returnReg);
	return retour;
    }
       
    private TLabel visit (LLabel label) {
	auto lbl = new TLabel (label.id);
	lbl.insts = visitInstructions (label.insts);	
	return lbl;
    }

    private TInstList visitInstructions (LInstList inst) {
	auto ret = new TInstList;
	foreach (it ; inst.insts) {
	    ret += visit (it);
	}
	return ret;
    }

    private TInstList visit (LInst inst) {
	if (auto write = cast (LWrite) (inst)) return visitWrite (write);
	assert (false, "TODO, visit (LInst)");
    }

    private TInstList visitWrite (LWrite write) {
	auto right = visitExpression (write.right);
	auto left = visitExpression (write.left);
	auto fin = new TInstList ();
	fin += (right.what + left.what);
	fin += (new TWrite (right.where, left.where));
	return fin;
    }

    private TInstPaire visitExpression (LExp elem) {
	if (auto reg = cast(LRegRead) elem) return visitRegRead (reg);
	else if (auto co = cast (LConst) elem) return visitConst (co);
	assert (false, "TODO, visitExpression (LExp)");
    }

    private TInstPaire visitRegRead (LRegRead reg) {
	return new TInstPaire (new TRegRead (visit (reg.data), reg.begin, reg.size), new TInstList);
    }

    private TReg visit (LData data) {
	if (auto reg = cast(LReg) data) return visit (reg);
	assert (false, "TODO, visit (LData)");
    }			       
			       
    private TInstPaire visitConst (LConst co) {
	if (auto by = cast(LConstByte) (co))
	    return new TInstPaire (new TConstByte (by.value), new TInstList);
	else if (auto dw = cast(LConstDWord) (co))
	    return new TInstPaire (new TConstDWord (dw.value), new TInstList);
	else if (auto qw = cast(LConstQWord) (co))
	    return new TInstPaire (new TConstQWord (qw.value), new TInstList);
	else if (auto lf = cast(LConstFloat) (co))
	    return new TInstPaire (new TConstFloat (lf.value), new TInstList);
	else if (auto ld = cast(LConstDouble) (co))
	    return new TInstPaire (new TConstDouble (ld.value), new TInstList);
	assert (false, "TODO, visitConst (LConst co)");
    }

    private TReg visit (LReg reg) {
	if (reg !is null) {
	    return new TReg (reg.id, reg.size);
	} else return null;
    }
    
    
}
