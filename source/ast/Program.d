module ast.Program;
import std.container, ast.Declaration;
import std.stdio, std.string;

class Program {

    private Array!Declaration _decls;
    
    this (Array!Declaration decls) {
	this._decls = decls;
    }

    void declare () {
	foreach (it ; this._decls) {
	    it.declare ();
	}
    }
    
    void print (int nb = 0) {
	writeln ("<Program>");
	foreach (it ; this._decls) {
	    it.print (nb + 4);
	}
    }
    
}
