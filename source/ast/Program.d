module ast.Program;
import std.container, ast.Declaration;
import std.stdio, std.string, std.path;
import syntax.Word;
import ast.Import;
import semantic.pack.Table, utils.Mangler;
public import semantic.pack.Module;

/**
 La classe qui va contenir les informations syntaxique de tout un fichier
 */
class Program {

    private Array!Declaration _decls;
    
    static Word [] __declareAtBegins__;

    private Word _locus;
    
    this (Word token, Array!Declaration decls) {
	__declareAtBegins__ = [
			       Word (Location (0, 0, 0, "core/int.yr"), "core/int", false),
			       Word (Location (0, 0, 0, "core/string.yr"), "core/string", false),
			       Word (Location (0, 0, 0, "core/stdio.yr"), "core/stdio", false)
	];
	this._locus = token;
	this._decls = decls;
    }

    /**
     Declare les informations dans la table de symbole
     */
    void declare () {
	string name = this._locus.locus.file;
	if (name.extension == ".yr")
	    name = name [0 .. name.lastIndexOf (".")];
	Table.instance.setCurrentSpace (null, Mangler.mangle!"file" (name));
	foreach (it ; __declareAtBegins__) {
	    if (this._locus.locus.file != it.str ~ ".yr") {
		auto _imp = new Import (it, make!(Array!Word)(it));
		_imp.declare ();
	    }
	}
	
	foreach (it ; this._decls) {
	    it.declare ();
	}
    }

    /**
     Declare toutes les informations dans la table des symboles comme étant des éléments externes.
     */
    void declareAsExtern (string name, Module mod) {
	if (name.extension == ".yr")
	    name = name [0 .. name.lastIndexOf (".")];
	Table.instance.setCurrentSpace (null, Mangler.mangle!"file" (name));
	foreach (it ; __declareAtBegins__) {
	    if (this._locus.locus.file != it.str ~ ".yr") {
		auto _imp = new Import (it, make!(Array!Word)(it));
		_imp.declare ();
	    }
	}
		
	foreach (it ; this._decls) {
	    it.declareAsExtern (mod);
	}
    }

    void file (string locus) {
	this._locus.locus.file = locus;
    }
    
    /**
     Affiche le programme sous forme d'arbre
     Params:
     nb = l'offset courant
     */
    void print (int nb = 0) {
	writeln ("<Program>");
	foreach (it ; this._decls) {
	    it.print (nb + 4);
	}
    }
    
}
