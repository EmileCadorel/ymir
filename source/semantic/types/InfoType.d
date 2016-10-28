module semantic.types.InfoType;
import syntax.Word, ast.Expression, utils.YmirException;
import std.outbuffer;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.CharInfo, semantic.types.StringInfo;
import semantic.types.FloatInfo;

class NotATemplate : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'est pas un template :", Colors.RED, Colors.RESET, Colors.GREEN, token.str, Colors.RESET);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }
    
}

class UndefinedType : YmirException {
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'existe pas :", Colors.RED, Colors.RESET, Colors.GREEN, token.str, Colors.RESET);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);

	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
}

class InfoType {
   
    static InfoType function (Word, Expression[]) [string] creators;

    static this () {
	creators = ["int" : &IntInfo.create,
		    "bool" : &BoolInfo.create,
		    "string" : &StringInfo.create,
		    "float" : &FloatInfo.create,
		    "char" : &CharInfo.create];
    }    
    
    static InfoType factory (Word word, Expression [] templates) {
	auto it = (word.str in creators);
	if (it !is null) return (*it) (word, templates);
	throw new UndefinedType (word);
    }
    
    static bool exist (string name) {
	return (name in creators) !is null;
    }

    string typeString () {
	return "";
    }

    InfoType BinaryOp (Word token, Expression right) {
	return null;
    }

    InfoType BinaryOpRight (Word token, Expression left) {
	return null;
    }

    InfoType clone () {
	return null;
    }
    
}
