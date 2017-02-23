import std.stdio, utils.YmirException;
import syntax.Visitor, semantic.pack.FrameTable;
import target.TFrame;
import std.outbuffer, lint.LVisitor, lint.LFrame;
import std.container, amd64.AMDVisitor, std.path;
import syntax.Lexer, target.TRodata, std.process;
import std.algorithm, syntax.Word;
import utils.Options, std.file;
import semantic.pack.Table;
import semantic.pack.Frame;
import semantic.types.ArrayUtils;
import semantic.types.StringUtils;
import semantic.types.ClassUtils;
import semantic.types.RangeUtils;
import semantic.types.StructUtils;
import semantic.types.StructInfo;

void semanticTime (string file) {
    Visitor visitor = new Visitor (file);
    auto prog = visitor.visit ();
    Table.instance.purge ();
    Table.instance.setCurrentSpace (Frame.mangle (file [0 .. $ - 3]));
    prog.declare ();
    
    auto error = 0;
    foreach (it ; FrameTable.instance.structs) {
	auto name = Word.eof;
	name.str = it.name;
	auto type = cast (StructInfo) it.create (name, []);
	StructUtils.createCstStruct (type.name, type.params);
	StructUtils.createDstStruct (type.name, type.params);
    }
    
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

string preCompiled (string name) {    
    if (Options.instance.isOn (OptionEnum.STD_COMPILATION)) {
	ArrayUtils.createFunctions ();
	StringUtils.createFunctions ();
	ClassUtils.createFunctions ();
	RangeUtils.createFunctions ();
	
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

string compileTemplates (string name) {
    Array!LFrame frames;
    auto visitor = new LVisitor ();
    foreach (it ; FrameTable.instance.templates) {
	frames.insertBack (visitor.visit (it));
    }
    
    foreach (key, value ; LFrame.preCompiled) {
	if (!value.isStd) {
	    frames.insertBack (value);
	}
	LFrame.preCompiled.remove (key);
    }
    
    debug {
	writeln (" ------------------------ TEMPLATES ------------------------");
	foreach (it ; frames) {
	    writeln (it);
	}
	writeln (" ------------------------ FIN-TEMPLATES ------------------------");
    }
    
    auto target = targetTime (frames);
    toFile (target, name);
    return name;
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
	    FrameTable.instance.clearImport ();
	    FrameTable.instance.structs.clear ();
	    
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

	files ~= [compileTemplates ("__templates__.s")];
	if (auto name = preCompiled ("__precompiled__.s"))
	    files ~= [name];	

	string [] options;
	if (Options.instance.isOn (OptionEnum.DEBUG))
	    options ~= ["-g"];
	if (Options.instance.isOn (OptionEnum.ASSEMBLE))
	    options ~= ["-c"];
	
	if (!Options.instance.isOn (OptionEnum.COMPILE)) {
	    auto pid = spawnProcess (["gcc"] ~
				     options ~
				     files ~
				     Options.instance.libs);
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
	debug {
	    throw yme;
	}
    } catch (ErrorOccurs occurs) {
	occurs.print ();
    }
}
