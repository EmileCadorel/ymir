import std.stdio, utils.YmirException;
import syntax.Visitor, semantic.pack.FrameTable;
import std.outbuffer;

void main (string [] args) {
    if (args.length > 1) {
	try {
	    Visitor visitor = new Visitor (args [1]);
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
	    
	} catch (YmirException yme) {
	    yme.print ();
	} catch (ErrorOccurs occurs) {
	    occurs.print ();
	}
    } else {
	writeln ("Pas de fichier d'entree");
    }
}
