module ast.Program;
import std.container, ast.Declaration;
import std.stdio, std.string;


/**
 La classe qui va contenir les informations syntaxique de tout un fichier
 */
class Program {

    private Array!Declaration _decls;
    
    this (Array!Declaration decls) {
	this._decls = decls;
    }

    /**
     Declare les informations dans la table de symbole
     */
    void declare () {
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
