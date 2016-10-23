module semantic.pack.Module;
import semantic.pack.Symbol, semantic.pack.Scope;

class Module {

    private string _filename;
    private Scope _globalScope;

    this (string filename) {
	this._filename = filename;
    }
    
    Symbol get (string name) {
	return this._globalScope [name];
    }

    void insert (Symbol symbol) {
	this._globalScope [symbol.sym.str] = symbol;
    }
            
}
