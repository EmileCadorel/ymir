module syntax.SyntaxError;
import utils.YmirException;
import syntax.Word;
import std.outbuffer, utils.Singleton;
import std.file, std.stdio, std.conv;
import std.stdio;

class SyntaxError : YmirException {
    
    this (Word word) {
	OutBuffer buf = new OutBuffer();
	string line;
	buf.write (RED);
	buf.write ("Erreur de syntaxe " ~ RESET ~ ":");
	buf.write (word.locus.file);
	buf.write (":(" ~ to!string(word.locus.line) ~ ", " ~ to!string(word.locus.column) ~ ") : ");
	buf.write ("'" ~ word.str ~ "'\n");
	if (word.isEof ()) {
	    buf.write ("Fin de fichier inattendue\n");
	} else {
	    line = this.getLine (word.locus);
	    int j = 0;
	    for(; j < word.locus.column - 1 && j < line.length; j++) buf.write (line[j]);
	    buf.write(GREEN);
	    for(; j < word.locus.length + word.locus.column - 1  && j < line.length; j++) buf.write (line[j]);
	    buf.write (RESET);
	    for(; j < line.length; j++) buf.write (line[j]);
	    
	    for(int i = 0; i < word.locus.column - 1 && i < line.length; i++) {
		if (line [i] == '\t') buf.write ('\t');
		else buf.write (" ");
	    }
	    for(int i = 0; i < word.locus.length; i++) buf.write ("^");
	    buf.write ("\n");
	}
	msg = buf.toString();
    }

    this (Word word, string [] expected) {
	OutBuffer buf = new OutBuffer();
	string line;
	buf.write (RED);
	buf.write ("Erreur de syntaxe " ~ RESET ~ ":");
	buf.write (word.locus.file);
	buf.write (":(" ~ to!string(word.locus.line) ~ ", " ~ to!string(word.locus.column) ~ ") : ");
	buf.write ("'" ~ word.str ~ "' obtenue quand {");
	foreach (i ; 0 .. expected.length) {
	    buf.write ("'" ~ expected[i] ~ "'");
	    if (i < expected.length - 1) {
		buf.write (",");
	    }
	}
	buf.write ("} sont attendus \n");
	if (word.isEof ()) {
	    buf.write ("Fin de fichier inattendue\n");
	} else {
	    line = this.getLine (word.locus);
	    int j = 0;
	    for(; j < word.locus.column - 1 && j < line.length; j++) buf.write (line[j]);
	    buf.write(GREEN);
	    for(; j < word.locus.length + word.locus.column - 1  && j < line.length; j++) buf.write (line[j]);
	    buf.write (RESET);
	    for(; j < line.length; j++) buf.write (line[j]);
	    
	    for(int i = 0; i < word.locus.column - 1 && i < line.length; i++) {
		if (line [i] == '\t') buf.write ('\t');
		else buf.write (" ");
	    }
	    for(int i = 0; i < word.locus.length; i++) buf.write ("^");
	    buf.write ("\n");
	}
	msg = buf.toString();
    }
    

}


class Warning {

    string RESET = "\u001B[0m";
    string PURPLE = "\u001B[46m";
    
    void warning_at (TArgs...) (Location locus, string msg, TArgs params) {
	OutBuffer buf = new OutBuffer();
	string line;
	buf.write (PURPLE);
	buf.write ("Attention " ~ RESET ~ ":");
	buf.write (locus.file);
	buf.write (":(" ~ to!string(locus.line) ~ ", " ~ to!string(locus.column) ~ ") : ");
	buf.writefln (msg, params);
	write (buf.toString);
    }

    private string getLine (Location locus) {
	auto file = File (locus.file, "r");
	string cline = null;
	foreach (it ; 1 .. locus.line)
	    cline = file.readln ();
	return cline;
    }
    
    mixin Singleton!Warning;
}
