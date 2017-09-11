module ymir.compiler.Compiler;
import ymir._;

import std.stdio;
import std.outbuffer, std.file;
import std.container, std.path;
import std.algorithm;
import std.process;

class Compiler {

    private LVisitor _lintVisitor;

    private TVisitor _targetVisitor;    

    this (string [] args) {
	Options.instance.init (args);
	try {	
	    if (Options.instance.inputFiles == []) {
		throw new Exception ("Pas de fichier d'entree");
	    }
	    
	    chooseVisitor ();	    
	} catch (YmirException yme) {
	    yme.print ();
	    debug { throw yme; }
	} catch (ErrorOccurs occurs) {
	    occurs.print ();
	    debug { throw occurs; }
	}
    }
        
    void compile () {
	auto files = Options.instance.inputFiles;
	string [] outFiles;
	foreach (file ; files) {
	    this.semanticTime (file);
	    auto list = this.lintTime ();
	    debug {
		foreach (it ; list) writeln (it.toString);		
	    }
	    
	    auto target = this.targetTime (list);
	    auto _out = file ~ this._targetVisitor.extension;
	    this.toFile (target, _out);
	    outFiles ~= [_out];
	}
	if (auto name = preCompiled ("__precompiled__" ~ this._targetVisitor.extension))
	    outFiles ~= [name];
	
	this._targetVisitor.finalize (outFiles);
    }

    private void chooseVisitor () {
	if (auto op = Options.instance.getOption (OptionEnum.TARGET)) {
	    switch (op) {
	    case "asm" : this._targetVisitor = new AMDVisitor (); break;
	    default : throw new UnknownTarget (op);
	    }
	} else this._targetVisitor = new AMDVisitor ();

	if (auto op = Options.instance.getOption (OptionEnum.LINT)) {
	    switch (op) {
	    case "d" : this._lintVisitor = new DVisitor (); break;
	    case "l" : this._lintVisitor = new LVisitor (); break;
	    default : throw new UnknownLint (op);
	    }
	} else this._lintVisitor = new LVisitor ();
    }
    
    private string preCompiled (string name) {
	if (Options.instance.isOn (OptionEnum.STD_COMPILATION)) {
	    RangeUtils.createFunctions ();
	    this._lintVisitor.createFunctions ();
	
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

    private void toFile (Array!TFrame frames, string filename) {
	auto file = File (filename, "w");
	this._targetVisitor.toFile (frames, filename);
    }
    
    private Array!TFrame targetTime (Array!LFrame frames) {
	return this._targetVisitor.target (frames);
    }
    
    private Array!LFrame lintTime () {
	return this._lintVisitor.visit ();
    }
    
    private void semanticTime (string file) {
	auto visitor = new Visitor (file);
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

    
    

}
