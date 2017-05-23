module ast.Import;
import ast.Declaration;
import std.container;
import syntax.Word;
import semantic.pack.Table;
import syntax.Visitor;
import semantic.pack.Frame;
import utils.exception;
import semantic.pack.FrameTable;
import std.file;
import utils.Options;
import ast.Var, ast.Expression;

/**
 TODO
 Classe généré à la syntaxe par.
 Example:
 ---
 // TODO
 ---
 */
class Import : Declaration {

    private Array!Word _params;
    private Word _ident;
    
    this (Word begin, Array!Word params) {
	this._ident = begin;
	this._params = params;
    }

    override void declare () {
	auto space = Table.instance.namespace;
	foreach (it ; this._params) {
	    if (!Table.instance.wasImported (it.str)) {
		try {		
		    if (exists (it.str ~ ".yr")) {
			auto visitor = new Visitor (it.str ~ ".yr");
			Table.instance.addImport (it.str);
			auto prog = visitor.visit ();
			prog.declareAsExtern ();
		    } else {
			string path = Options.instance.getPath ();
			if (path[$ - 1] != '/') path ~= "/";
			if (!exists (path ~ it.str ~ ".yr"))
			    throw new ImportError (it);
			auto visitor = new Visitor (path ~ it.str ~ ".yr");
			Table.instance.addImport (it.str);
			auto prog = visitor.visit ();
			prog.declareAsExtern ();
		    }
		} catch (YmirException) {
		    throw new ImportError (it);
		}
	    }
	}
	
	Table.instance.resetCurrentSpace (space);
    }
           
    override void declareAsExtern () {
	if (this._isPublic) {
	    this.declare ();
	}
    }

    override Declaration templateReplace (Expression [string]) {
	return this;
    }    
    
}
