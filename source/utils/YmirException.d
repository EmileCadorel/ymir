module utils.YmirException;
import syntax.Word, std.stdio;

class YmirException : Exception {
        
    string RESET = "\u001B[0m";
    string PURPLE = "\u001B[46m";
    string RED = "\u001B[41m";
    string GREEN = "\u001B[42m";

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

    
}
