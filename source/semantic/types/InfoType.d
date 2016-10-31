module semantic.types.InfoType;
import syntax.Word, ast.Expression, utils.YmirException;
import std.outbuffer, utils.exception;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.CharInfo, semantic.types.StringInfo;
import semantic.types.FloatInfo, utils.exception;

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
    
    int size () {
	return 0;
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
