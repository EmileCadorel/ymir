import std.stdio;
import ymir._;

import std.outbuffer, std.file;
import std.container, std.path;
import std.algorithm;
import std.process;


void semanticTime (string file) {
    debug writeln ("COMPILING ", file);
       
    Visitor visitor = new Visitor (file);
    auto prog = visitor.visit ();
    Table.instance.purge ();
    FrameTable.instance.purge ();
    prog.declare ();
    
    auto error = 0;
    foreach (it ; FrameTable.instance.structs) {
	auto name = Word.eof;
	name.str = it.name;
	if (it.needCreation) {
	    auto type = cast (StructInfo) it.create (name, []);
	    StructUtils.createCstStruct (type);
	}
    }
    
    foreach (it ; FrameTable.instance.objects) {
	if (it.impl.needCreation) {
	    auto type = cast (StructInfo) it.create ();
	    StructUtils.createCstStruct (type);
	}
    }
    
    foreach (it ; FrameTable.instance.pures) {		
	try {
	    it.validate ();		
	} catch (YmirException yme) {
	    yme.print ();
	    error ++;
	    debug { throw yme; }
	} catch (ErrorOccurs occurs) {
	    error += occurs.nbError;
	    debug { throw occurs; }
	}
    }

    if (error > 0) throw new ErrorOccurs (error);    
}

Array!LFrame lintTime () {
    LVisitor visitor = new LVisitor ();    
    return visitor.visit ();
}

Array!TFrame targetTime (Array!LFrame frames) {
    AMDFile.reset ();
    return new AMDVisitor ().target (frames);    
}

string preCompiled (string name) {    
    if (Options.instance.isOn (OptionEnum.STD_COMPILATION)) {
	RangeUtils.createFunctions ();
	LVisitor.createFunctions ();
	
	debug {
	    writeln ("----------- PRECOMPILED-----------------");
	    foreach (it ; make!(Array!LFrame) (LFrame.preCompiled.values)) {
		writeln (it.toString);
	    }
	    writeln ("----------- PRECOMPILED-FIN -----------------");
	}

	auto target = targetTime (make!(Array!LFrame) (LFrame.preCompiled.values));
	
	toFile (target, name);
	return name;
    } 
    return null;
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

    file.write ("\t.data\n");
    foreach (it ; TData.insts.inst) {
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

	if (auto name = preCompiled ("__precompiled__.s"))
	    files ~= [name];	

	string [] options;
	if (Options.instance.isOn (OptionEnum.DEBUG))
	    options ~= ["-g"];
	if (Options.instance.isOn (OptionEnum.ASSEMBLE))
	    options ~= ["-c"];

	if (Options.instance.isOn (OptionEnum.TARGET))
	    options ~= ["-o", Options.instance.getOption (OptionEnum.TARGET)];
	
	if (!Options.instance.isOn (OptionEnum.COMPILE)) {
	    auto pid = spawnProcess (["gcc"] ~				     
				     options ~
				     files ~
				     Options.instance.libs ~
				     ["-lm"] ~
				     Options.instance.links
				     
	    );
	    if (wait (pid) != 0) assert ("Compilation raté");	
	}
	
	bool del = true;
	if (!Options.instance.isOn (OptionEnum.COMPILE)) {
	    debug del = false;
	    if (del) {
		foreach (it ; files) std.file.remove (it);		
	    }
	}
	
	
    } catch (YmirException yme) {
	yme.print ();
	debug { throw yme; }
    } catch (ErrorOccurs occurs) {
	occurs.print ();
	debug { throw occurs; }
    }
}
