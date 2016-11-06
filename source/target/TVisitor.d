module target.TVisitor;
import lint.LFrame, target.TFrame, target.TLabel, lint.LLabel;
import lint.LReg, target.TReg;
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
	TFrame retour = new TFrame (frame.number);
	retour.entryLbl = visit (frame.entryLbl);
	retour.returnLbl = visit (frame.returnLbl);
	foreach (it ; frame.args) {
	    retour.paramRegs.insertBack (visit (it));
	}
	retour.returnReg = visit (frame.returnReg);
	return retour;
    }
       
    private TLabel visit (LLabel label) {
	return new TLabel (label.id);
    }

    private TReg visit (LReg reg) {
	if (reg !is null) {
	    return new TReg (reg.id, reg.size);
	} else return null;
    }
    
    
}
