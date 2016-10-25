import std.stdio, utils.YmirException;
import syntax.Visitor, semantic.pack.FrameTable;
import std.outbuffer;

void main (string [] args) {
    if (args.length > 1) {
	try {
	    Visitor visitor = new Visitor (args [1]);
	    auto prog = visitor.visit ();
	    prog.declare ();
	    foreach (it ; FrameTable.instance.pures) {
		it.validate ();
	    }
	    OutBuffer buf = new OutBuffer;
	    foreach (it ; FrameTable.instance.finals) {
		it.toC (buf);
	    }
	    writeln (buf.toString);
	} catch (YmirException yme) {
	    yme.print ();
	} catch (ErrorOccurs occurs) {
	    occurs.print ();
	}
    } else {
	writeln ("Pas de fichier d'entree");
    }
}
