import std.stdio;
import syntax.Visitor, semantic.pack.FrameTable;

void main (string [] args) {
    if (args.length > 1) {
	Visitor visitor = new Visitor (args [1]);
	auto prog = visitor.visit ();
	prog.declare ();
	foreach (it ; FrameTable.instance.pures) {
	    it.validate ();
	}	
    } else {
	writeln ("Pas de fichier d'entree");
    }
}
