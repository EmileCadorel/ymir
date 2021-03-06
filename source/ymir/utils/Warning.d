module ymir.utils.Warning;
import ymir.utils._;
import ymir.syntax._;

import std.string, std.outbuffer, std.stdio, std.conv;;

/**
 Affiche des message d'avertissement.
 */
class Warning {

    string RESET = "\u001B[0m";

    /**
     Affiche un message d'avertissement en fonction d'une position.
     Params:
     locus = l'emplacement de l'avertissement
     msg = un message sous forme de format
     params = les paramètres du format
     */
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

    /**
     Ajoute une ligne avec l'erreur surligné en Jaune.
     Params:
     buf = le buffer ou l'on veut ajouter la ligne
     locus = l'emplacement de l'erreur
     */
    protected void addLine (ref OutBuffer buf, Location locus) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    auto leftLine = center (format ("%d", locus.line), 4, ' ');
	    auto padd = center ("", leftLine.length, ' ');
	    buf.writefln ("%s  --> %s:(%d,%d)%s\n%s%s| %s", Colors.BOLD.value, locus.file, locus.line, locus.column, Colors.RESET.value,
			  Colors.BOLD.value,
			  padd, 
			  Colors.RESET.value			  
	    );
	    
	    buf.writef ("%s%s| %s%s%s%s%s%s",
			Colors.BOLD.value,
			leftLine, 
			Colors.RESET.value,
			line[0 .. locus.column - 1],
			Colors.YELLOW.value,
			line[locus.column - 1 .. locus.column + locus.length - 1],
			Colors.RESET.value,
			line[locus.column + locus.length - 1.. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    buf.writef ("%s%s| %s", Colors.BOLD.value, padd, Colors.RESET.value);
	    foreach (it ; 0 .. locus.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s",  rightJustify ("", locus.length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    
    /**
     Recupère une ligne dans un fichier
     Params:
     locus = l'emplacement
     */
    private string getLine (Location locus) {
	auto file = File (locus.file, "r");
	string cline = null;
	foreach (it ; 0 .. locus.line)
	    cline = file.readln ();
	return cline;
    }

        
    mixin Singleton!Warning;
}
