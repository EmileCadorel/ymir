module semantic.pack.Module;
import semantic.pack.Symbol, semantic.pack.Scope;

/**
 Cette classe contient les informations d'un import
 TODO, Elle est a compléter
 */
class Module {

    /** le nom du fichier importé */
    private string _filename;

    /** Le scope global de la frame qui va contenir toutes le declaration importable */
    private Scope _globalScope;

    this (string filename) {
	this._filename = filename;
    }

    /**
     Params:
     name = le nom du symbole recherché
     Returns: le symbol identifié par name
     */    
    Symbol get (string name) {
	return this._globalScope [name];
    }

    /** 
     Insert un nouveau symbol
     Params:
     symbol = le symbole à définir
     */
    void insert (Symbol symbol) {
	this._globalScope [symbol.sym.str] = symbol;
    }
            
}
