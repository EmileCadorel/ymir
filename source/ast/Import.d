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
	auto globSpace = Table.instance.namespace;
	foreach (it ; this._params) {
	    try {
		string name = it.str ~ ".yr";
		if (!exists (name)) {
		    string path = Options.instance.getPath ();
		    if (path[$ - 1] != '/') path ~= "/";
		    name = path ~ it.str ~ ".yr";
		    if (!exists (name))
			throw new ImportError (it);
		}
		auto space = new Namespace (it.str);
		if (!Table.instance.moduleExists (space)) { 
		    auto visitor = new Visitor (name);
		    auto mod = Table.instance.addModule (space);
		    mod.addOpen (globSpace);
		    auto prog = visitor.visit ();
		    prog.declareAsExtern (it.str, mod);
		}
		Table.instance.openModuleForSpace (space, globSpace);	    
		Table.instance.resetCurrentSpace (globSpace);
	    } catch (YmirException err) {
		err.print;
		throw new ImportError (it);
	    }
	}	
    }
           
    override void declareAsExtern (Module mod_) {
	auto globSpace = Table.instance.namespace;
	foreach (it ; this._params) {
	    try {
		string name = it.str ~ ".yr";
		if (!exists (name)) {
		    string path = Options.instance.getPath ();
		    if (path[$ - 1] != '/') path ~= "/";
		    name = path ~ it.str ~ ".yr";
		    if (!exists (name))
			throw new ImportError (it);
		}
		auto space = new Namespace (it.str);
		if (!Table.instance.moduleExists (space)) { 
		    auto visitor = new Visitor (name);
		    auto mod = Table.instance.addModule (space);
		    mod.addOpen (globSpace);
		    auto prog = visitor.visit ();
		    prog.declareAsExtern (it.str, mod);		    
		    if (this._isPublic) {
			mod_.addPublicOpen (mod.space);
		    }
		}		
		Table.instance.openModuleForSpace (space, globSpace);	    
		Table.instance.resetCurrentSpace (globSpace);
	    } catch (YmirException err) {
		err.print;
		throw new ImportError (it);
	    }	     
	}	
    }

    override Declaration templateReplace (Expression [string]) {
	return this;
    }    
    
}
