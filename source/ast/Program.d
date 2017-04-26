module ast.Program;
import std.container, ast.Declaration;
import std.stdio, std.string;
import syntax.Word;
import ast.Import;


/**
 La classe qui va contenir les informations syntaxique de tout un fichier
 */
class Program {

    private Array!Declaration _decls;
    
    static Word [] __declareAtBegins__;

    private Word _locus;
    
    this (Word token, Array!Declaration decls) {
	__declareAtBegins__ = [
	    Word (Word.eof.locus, "core/int", false),
	    Word (Word.eof.locus, "core/string", false)
	];
	this._locus = token;
	this._decls = decls;
    }

    /**
     Declare les informations dans la table de symbole
     */
    void declare () {
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
    void declareAsExtern () {
	foreach (it ; this._decls) {
	    it.declareAsExtern ();
	}
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
