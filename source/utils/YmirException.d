module utils.YmirException;
import syntax.Word, std.stdio, std.typecons;
import std.outbuffer;

alias Color = Tuple!(string, "value");

enum Colors : Color {
    RESET = Color ("\u001B[0m"),
    PURPLE = Color ("\u001B[1;35m"),
    BLUE = Color ("\u001B[1;36m"),
    YELLOW = Color ("\u001B[1;33m"),
    RED = Color ("\u001B[1;31m"),
    GREEN = Color ("\u001B[1;32m")	
}

class ErrorOccurs : Exception {
    this (ulong nb) {
	super ("");
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s: %d", Colors.RED.value, Colors.RESET.value, nb);
	msg = buf.toString ();
	this._nbError = nb;
    }

    void print () {
	writeln (this.msg);
    }
    
    ref ulong nbError () {
	return this._nbError;
    }
    
    private ulong _nbError;
    
}

class YmirException : Exception {       
 
    this () {
	super ("");
    }
    
    this (string msg) {
	super (msg);
    }

    protected string getLine (Location locus) {
	auto file = File (locus.file, "r");
	string cline = null;
	foreach (it ; 0 .. locus.line)
	    cline = file.readln ();
	return cline;
    }

    void print () {
	writeln (this.msg);
    }
    

}
