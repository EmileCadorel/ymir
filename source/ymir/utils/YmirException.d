module ymir.utils.YmirException;
import ymir.syntax._;

import std.stdio, std.typecons;
import std.outbuffer, std.string;

/**
 Le tuple Color est definis par une chaine
 */
alias Color = Tuple!(string, "value");

/**
 L'enumeration des couleurs disponible 
 */
enum Colors : Color {
    RESET = Color ("\u001B[0m"),
    PURPLE = Color ("\u001B[1;35m"),
    BLUE = Color ("\u001B[1;36m"),
    YELLOW = Color ("\u001B[1;33m"),
    RED = Color ("\u001B[1;31m"),
    GREEN = Color ("\u001B[1;32m"),
    BOLD = Color ("\u001B[1;50m")
}

/**
 Exception qui informe que des erreurs sont survenus.
 */
class ErrorOccurs : Exception {

    /**
     Params:
     nb = le nombre d'erreurs
     */
    this (ulong nb) {
	super ("");
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s: %d", Colors.RED.value, Colors.RESET.value, nb);
	msg = buf.toString ();
	this._nbError = nb;
    }

    /**
     Affiche le message d'erreur
     */
    void print () {
	writeln (this.msg);
    }

    /**
     Returns le nombre d'erreur
     */
    ref ulong nbError () {
	return this._nbError;
    }

    /// Le nombre d'erreur
    private ulong _nbError;
    
}

/**
 Ancêtre des erreurs de compilation.
*/
class YmirException : Exception {       
 
    this () {
	super ("");
    }

    /**
     Params:
     msg = Le message de l'erreur
     */
    this (string msg) {
	super (msg);
	this.msg = msg;
    }

    /**
     Params:
     locus = l'emplacement de la ligne
     Returns retourne la ligne x d'un fichier
     */
    private string getLine (Location locus) {	
	import std.path, std.string;
	if (locus.file.extension == ".yr") {
	    auto file = File (locus.file, "r");
	    string cline = null;
	    foreach (it ; 0 .. locus.line)
		cline = file.readln ();
	    return cline;
	} else {
	    import std.stdio;
	    auto lines = locus.mixLines.splitLines ();
	    return lines [locus.line - 1];
	}
    }

    ulong computeMid (ref string mid, string word, string line, ulong begin, ulong end) {
	import std.algorithm;
	auto end2 = begin;
	foreach (it ; 0 .. min (word.length, end - begin)) {
	    if (word [it] != line [begin + it]) break;
	    else end2 ++;
	}
	mid = line [begin .. end2];
	return end2;
    }
    
    /**
     Ajoute une ligne dans un buffer avec l'erreur en Jaune.
     Params:
     buf = le buffer a remplir
     word = l'emplacement
     */
    void addLine (ref OutBuffer buf, Location locus) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    auto leftLine = center (format ("%d", locus.line), 3, ' ');
	    auto padd = center ("", leftLine.length, ' ');
	    buf.writefln ("%s  --> %s:(%d,%d)%s\n%s%s | %s", Colors.BOLD.value, locus.file, locus.line, locus.column, Colors.RESET.value,
			  Colors.BOLD.value,
			  padd,
			  Colors.RESET.value			  
	    );
	    
	    buf.writef ("%s%s | %s%s%s%s%s%s",
			Colors.BOLD.value,
			leftLine, 
			Colors.RESET.value,
			line[0 .. locus.column - 1],
			Colors.YELLOW.value,
			line[locus.column - 1 .. locus.column + locus.length - 1],
			Colors.RESET.value,
			line[locus.column + locus.length - 1 .. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    buf.writef ("%s%s | %s", Colors.BOLD.value, padd, Colors.RESET.value);
	    foreach (it ; 0 .. locus.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", locus.length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 	
	
    
    /**
     Ajoute une ligne dans un buffer avec l'erreur en Jaune.
     Params:
     buf = le buffer a remplir
     word = l'emplacement
     */
    void addLine (ref OutBuffer buf, Word word) {
	auto locus = word.locus;
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    auto leftLine = center (format ("%d", locus.line), 3, ' ');
	    auto padd = center ("", leftLine.length, ' ');
	    buf.writefln ("%s  --> %s:(%d,%d)%s\n%s%s | %s", Colors.BOLD.value, locus.file, locus.line, locus.column, Colors.RESET.value,
			  Colors.BOLD.value,
			  padd,
			  Colors.RESET.value			  
	    );
	    
	    string mid;
	    auto end = computeMid (mid, word.str, line, locus.column - 1, locus.column + locus.length - 1);
				   
	    buf.writef ("%s%s | %s%s%s%s%s%s",
			Colors.BOLD.value,
			leftLine, 
			Colors.RESET.value,
			line [0 .. locus.column - 1],
			Colors.YELLOW.value,
			mid, 
			Colors.RESET.value,
			line [end .. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    buf.writef ("%s%s | %s", Colors.BOLD.value, padd, Colors.RESET.value);
	    foreach (it ; 0 .. locus.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", end - locus.column + 1, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 


    /**
     Ajoute une ligne dans un buffer avec l'erreur en Jaune.
     Params:
     buf = le buffer a remplir
     locus = le debut de l'emplacement
     locus2 = le deuxième emplacement
     */
    protected void addLine (ref OutBuffer buf, Word word, Word word2) {
	auto locus = word.locus, locus2 = word2.locus;
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    auto leftLine = center (format ("%d", locus.line), 3, ' ');
	    auto padd = center ("", leftLine.length, ' ');
	    buf.writefln ("%s  --> %s:(%d,%d)%s\n%s%s | %s", Colors.BOLD.value, locus.file, locus.line, locus.column, Colors.RESET.value,
			  Colors.BOLD.value,
			  padd, 
			  Colors.RESET.value			  
	    );
	    string mid, mid2;
	    auto end1 = computeMid (mid, word.str, line, locus.column - 1, locus.column + locus.length - 1);
	    auto end2 = computeMid (mid2, word2.str, line, locus2.column - 1, locus2.column + locus2.length - 1);
	    
	    buf.writef ("%s%s | %s%s%s%s%s%s%s%s%s%s",
			Colors.BOLD.value,
			leftLine,
			Colors.RESET.value,
			line[0 .. locus.column - 1],
			Colors.YELLOW.value,
			mid,
			Colors.RESET.value,
			line [end1 .. locus2.column - 1],
			Colors.YELLOW.value,
			mid2,
			Colors.RESET.value,
			line [end2 .. $]);
	    
	    if (line[$-1] != '\n') buf.write ("\n");
	    buf.writef ("%s%s | %s", Colors.BOLD.value, padd, Colors.RESET.value);
	    foreach (it ; 0 .. locus.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writef ("%s", rightJustify ("", end1 - locus.column + 1, '^'));
	    foreach (it ; end1 .. locus2.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", end2 - locus2.column + 1, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    /**
     Ajoute une ligne dans un buffer avec l'erreur en Jaune.
     Params:
     buf = le buffer a remplir
     locus = le debut de l'emplacement
     index = le decalage par rapport à l'emplacement
     lenght = la longueur de l'erreur
     */
    void addLine (ref OutBuffer buf, Word word, ulong index, ulong length) {
	auto locus = word.locus;
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    auto leftLine = center (format ("%d", locus.line), 3, ' ');
	    auto padd = center ("", leftLine.length, ' ');
	    buf.writefln ("%s  --> %s:(%d,%d)%s\n%s%s | %s", Colors.BOLD.value, locus.file, locus.line, locus.column, Colors.RESET.value,
			  Colors.BOLD.value,
			  padd, 
			  Colors.RESET.value			  
	    );

	    string mid;
	    auto end = computeMid (mid, word.str, line, locus.column + index, locus.column + index + length);
	    
	    buf.writef ("%s%s | %s%s%s%s%s%s",
			Colors.BOLD.value,
			leftLine, 
			Colors.RESET.value,
			line[0 .. locus.column + index],
			Colors.YELLOW.value,
			mid, 
			Colors.RESET.value,
			line[end .. $]);
	    
	    if (line[$-1] != '\n') buf.write ("\n");
	    buf.writef ("%s%s | %s", Colors.BOLD.value, padd, Colors.RESET.value);
	    foreach (it ; 0 .. locus.column + index) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", end - locus.column + index + 1, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    /**
     Affiche le message d'erreur
     */
    void print () {
	writeln (this.msg);
    }
    

}
