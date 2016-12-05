module utils.Warning;
import utils.YmirException, utils.Singleton;
import syntax.Word, std.outbuffer, std.stdio, std.conv;
import std.string;

class Warning {

    string RESET = "\u001B[0m";
    
    void warning_at (TArgs...) (Location locus, string msg, TArgs params) {
	OutBuffer buf = new OutBuffer();
	string line;
	buf.write (Colors.YELLOW.value);
	buf.write ("Attention " ~ Colors.RESET.value ~ ":");
	buf.write (locus.file);
	buf.write (":(" ~ to!string(locus.line) ~ ", " ~ to!string(locus.column) ~ ") : ");
	buf.writefln (msg, params);
	addLine (buf, locus);
	write (buf.toString);
    }


    protected void addLine (ref OutBuffer buf, Location locus) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    buf.writef ("%s%s%s%s%s", line[0 .. locus.column],
			Colors.YELLOW.value,
			line[locus.column .. locus.column + locus.length],
			Colors.RESET.value,
			line[locus.column + locus.length .. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    foreach (it ; 0 .. locus.column) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s",  rightJustify ("", locus.length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    
    private string getLine (Location locus) {
	auto file = File (locus.file, "r");
	string cline = null;
	foreach (it ; 0 .. locus.line)
	    cline = file.readln ();
	return cline;
    }

        
    mixin Singleton!Warning;
}
