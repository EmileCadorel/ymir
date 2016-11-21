module utils.YmirException;
import syntax.Word, std.stdio, std.typecons;
import std.outbuffer, std.string;

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

    private string getLine (Location locus) {
	auto file = File (locus.file, "r");
	string cline = null;
	foreach (it ; 0 .. locus.line)
	    cline = file.readln ();
	return cline;
    }

    protected void addLine (ref OutBuffer buf, Location locus) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    buf.writef ("%s%s%s%s%s", line[0 .. locus.column - 1],
			Colors.YELLOW.value,
			line[locus.column - 1 .. locus.column + locus.length - 1],
			Colors.RESET.value,
			line[locus.column + locus.length - 1 .. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    foreach (it ; 0 .. locus.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", locus.length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    protected void addLine (ref OutBuffer buf, Location locus, ulong index, ulong length) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    buf.writef ("%s%s%s%s%s", line[0 .. locus.column + index],
			Colors.YELLOW.value,
			line[locus.column + index .. locus.column + index + length],
			Colors.RESET.value,
			line[locus.column + index + length .. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    foreach (it ; 0 .. locus.column + index) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    
    void print () {
	writeln (this.msg);
    }
    

}
