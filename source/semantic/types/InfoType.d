module semantic.types.InfoType;
import syntax.Word, ast.Expression, utils.YmirException;
import std.outbuffer;
import semantic.types.IntInfo;

class NotATemplate : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'est pas un template :", RED, RESET, GREEN, token.str, RESET);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	auto line = getLine (token.locus);
	buf.write (line);
	foreach (i ; 0 .. token.locus.column - 1) {
	    if (line[i] == '\t') buf.write ("\t");
	    else buf.write (" ");
	}

	foreach (it ; 0 .. token.locus.length)
		 buf.write ("^");
	
	buf.write ("\n");
	msg = buf.toString();        

    }
    
}

class UndefinedType : YmirException {
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'existe pas :", RED, RESET, GREEN, token.str, RESET);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	auto line = getLine (token.locus);
	buf.write (line);
	foreach (i ; 0 .. token.locus.column - 1) {
	    if (line[i] == '\t') buf.write ("\t");
	    else buf.write (" ");
	}
	
	foreach (it ; 0 .. token.locus.length)
		 buf.write ("^");
	
	buf.write ("\n");
	msg = buf.toString();        
    }
}

class InfoType {
   
    static InfoType function (Word, Expression[]) [string] creators;

    static this () {
	creators = ["int" : &IntInfo.create];
    }    
    
    static InfoType factory (Word word, Expression [] templates) {
	auto it = (word.str in creators);
	if (it !is null) return (*it) (word, templates);
	throw new UndefinedType (word);
    }
    
    static bool exist (string name) {
	return (name in creators) !is null;
    }

}
