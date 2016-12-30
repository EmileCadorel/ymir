import std.stdio, utils.YmirException;
import syntax.Visitor, semantic.pack.FrameTable;
import target.TFrame;
import std.outbuffer, lint.LVisitor, lint.LFrame;
import std.container, amd64.AMDVisitor, std.path;
import syntax.Lexer, target.TRodata, std.process;
import std.algorithm;
import utils.Options, std.file;
import semantic.pack.Table;
import semantic.pack.Frame;

void semanticTime (string file) {
    Visitor visitor = new Visitor (file);
    auto prog = visitor.visit ();
    Table.instance.purge ();
    Table.instance.setCurrentSpace (Frame.mangle (file));
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
    return new AMDVisitor ().target (frames);    
}

void toFile (Array!TFrame frames, string filename) {
    auto file = File (filename, "w");
    file.write ("\t.section .rodata\n");
    foreach (it ; TRodata.insts.inst) {
	file.write (it);
    }
    
    file.write ("\t.text\n");
    foreach (it ; frames) {
	file.write (it.toString ());
    }
}


void main (string [] args) {
    Options.instance.init (args);
    try {
	if (Options.instance.inputFiles == []) {
	    throw new Exception ("Pas de fichier d'entree");
	}
	
	string [] files;
	foreach (file ; Options.instance.inputFiles) {	
	    FrameTable.instance.pures.clear ();
	    FrameTable.instance.finals.clear ();
	    semanticTime (file);
	    auto list = lintTime ();		
	    debug {
		foreach (it ; list) {
		    writeln (it.toString);
		}
	    }
	    auto target = targetTime (list);
	    
	    toFile (target, file ~ ".s");
	    files ~= [file ~ ".s"];
	}	

	if (Options.instance.isOn (OptionEnum.DEBUG)) {
	    auto pid = spawnProcess (["gcc"] ~ ["-g"] ~ files);
	    writeln ("linking");
	    if (wait (pid) != 0) assert ("Compilation raté");
	} else {
	    auto pid = spawnProcess (["gcc"] ~ files);
	    writeln ("linking");
	    if (wait (pid) != 0) assert ("Compilation raté");
	}
	   	
	bool del = true;
	debug del = false;
	if (del) {
	    foreach (it ; files) std.file.remove (it);		
	}
	
	
    } catch (YmirException yme) {
	yme.print ();
	debug {
	    throw yme;
	}
    } catch (ErrorOccurs occurs) {
	occurs.print ();
    }
}
