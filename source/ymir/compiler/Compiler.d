module ymir.compiler.Compiler;
import ymir.target._;
import ymir.lint._;
import ymir.dtarget._;
import ymir.amd64._;
import ymir.syntax._;
import ymir.semantic._;
import ymir.utils._;

import std.stdio;
import std.outbuffer, std.file;
import std.container, std.path;
import std.algorithm, std.string;
import std.process;

alias COMPILER = Compiler.instance;

class Compiler {

    private LVisitor _lintVisitor;

    private TVisitor _targetVisitor;    
    
    void init (string [] args) {
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

    bool isToLint () {
	return !cast (DVisitor) this._lintVisitor;
    }
    
    T getLVisitor (T : LVisitor) () {
	return cast (T) this._lintVisitor;
    }
    
    void compile () {
	auto files = Options.instance.inputFiles;
	string [] outFiles;
	if (auto d = cast (DVisitor) this._lintVisitor) d.initOutDir ();
	foreach (file ; files) {
	    this.semanticTime (file);
	    auto list = this.lintTime ();
	    debug {
		foreach (it ; list) writeln (it.toString);		
	    }
	    
	    if (!cast (DVisitor) this._lintVisitor) {
		auto target = this.targetTime (list);
		auto _out = file [0 .. file.lastIndexOf (".")] ~ this._targetVisitor.extension;
		this.toFile (target, _out);
		outFiles ~= [_out];
	    } else if (auto d = cast (DVisitor) this._lintVisitor) {
		auto _out = file [0 .. file.lastIndexOf (".")];
		_out = d.toFile (list, _out, d.extension);
		d.clean ();
		outFiles ~= [_out];
	    }
	}
	if (!cast (DVisitor) this._lintVisitor) {
	    if (auto name = preCompiled ("__precompiled__" ~ this._targetVisitor.extension))
		outFiles ~= [name];
	    
	    this._targetVisitor.finalize (outFiles);
	} else if (auto d = cast (DVisitor) this._lintVisitor)
	    d.finalize (outFiles);
    }

    private void chooseVisitor () {
	if (auto op = Options.instance.getOption (OptionEnum.TARGET)) {
	    switch (op) {
	    case "asm" : this._targetVisitor = new AMDVisitor (); break;
	    default : throw new UnknownTarget (op);
	    }
	} else this._targetVisitor = new AMDVisitor ();

	if (auto op = Options.instance.getOption (OptionEnum.LINT)) {
	    switch (op.toUpper) {
	    case "D" : this._lintVisitor = new DVisitor (); break;
	    case "L" : this._lintVisitor = new LVisitor (); break;
	    default : throw new UnknownLint (op);
	    }
	} else this._lintVisitor = new DVisitor ();
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

	foreach (it ; FrameTable.instance.structs) {
	    auto name = Word.eof;
	    name.str = it.name;
	    if (it.needCreation) {
		auto type = cast (StructInfo) it.create (name);
		StructUtils.createCstStruct (type);
	    }
	}
    
	foreach (it ; FrameTable.instance.objects) {
	    if (it.impl.needCreation) {
		auto type = cast (StructInfo) it.create ();
		StructUtils.createCstStruct (type);
	    }
	}

	
    }

    
    mixin Singleton;
    
}
