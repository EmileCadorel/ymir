module lint.LVisitor;
import semantic.pack.FrameTable, semantic.pack.Frame;
import lint.LFrame, lint.LInstList, lint.LLabel, lint.LReg;
import semantic.types.VoidInfo;
import ast.all, std.container;

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
	    args.insertBack (new LReg (it.info.type.size));
	}
	
	return new LFrame (semFrame.name, entry, end, retReg, args, visit(semFrame.block));
    }

    private LInstList visit (Block block) {
	return new LInstList ();
    }

}


