import std.stdio, utils.YmirException;
import syntax.Visitor, semantic.pack.FrameTable;
import target.TFrame, ybyte.YBVisitor;
import std.outbuffer, lint.LVisitor, lint.LFrame;
import std.container;

void semanticTime (string args) {
    Visitor visitor = new Visitor (args);
    auto prog = visitor.visit ();
    prog.declare ();
    
    auto error = 0;
    foreach (it ; FrameTable.instance.pures) {		
	try {
	    it.validate ();		
	} catch (YmirException yme) {
	    yme.print ();
	    error ++;
	} catch (ErrorOccurs occurs) {
	    error += occurs.nbError;
	}
    }
    if (error > 0) throw new ErrorOccurs (error);    
}

Array!LFrame lintTime () {
    LVisitor visitor = new LVisitor ();    
    return visitor.visit ();
}

Array!TFrame targetTime (Array!LFrame frames) {
    TVisitor visitor = new YBVisitor ();
    return visitor.target (frames);
}



void main (string [] args) {
    if (args.length > 1) {
	try {
	    semanticTime (args[1]);
	    auto list = lintTime ();
	    
	    // 	    foreach (it ; list) {
	    // 	writeln (it);
	    // }

	    auto target = targetTime (list);
	    foreach (it ; target) {
		writeln (it);
	    }
	} catch (YmirException yme) {
	    yme.print ();
	} catch (ErrorOccurs occurs) {
	    occurs.print ();
	}
    } else {
	writeln ("Pas de fichier d'entree");
    }
}
