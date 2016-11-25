import std.stdio, utils.YmirException;
import syntax.Visitor, semantic.pack.FrameTable;
import target.TFrame, ybyte.YBVisitor;
import std.outbuffer, lint.LVisitor, lint.LFrame;
import std.container, amd64.AMDVisitor, std.path;
import syntax.Lexer;

string file (string [] args) {
    foreach (it ; args) {
	if (extension (it) == ".yr") return it;
    }
    return null;
}

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

Array!TFrame targetTime (Array!LFrame frames, string [] args) {
    TVisitor visitor;
    foreach (it ; args) {
	if (it == "-x64")  {
	    visitor = new AMDVisitor ();
	} else if (it == "-yb") {
	    visitor = new YBVisitor ();
	}
    }
    if (visitor !is null) 
	return visitor.target (frames);
    else return new AMDVisitor ().target (frames);    
}

void toFile (Array!TFrame frames, string [] args) {
    auto file = File ("out.s", "w");
    foreach (it ; frames) {
	file.write (it.toString ());
    }
}

void main (string [] args) {
    auto file = file (args);
    try {
	if (file is null) {
	    throw new Exception ("Pas de fichier d'entree");
	}
	semanticTime (file);
	auto list = lintTime ();
	auto target = targetTime (list, args);
	toFile (target, args);
    } catch (YmirException yme) {
	yme.print ();
    } catch (ErrorOccurs occurs) {
	occurs.print ();
    }
}
