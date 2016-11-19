module semantic.types.CharInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType, utils.exception;

class CharInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new CharInfo ();
    }

    override string typeString () {
	return "char";
    }

    override InfoType clone () {
	return new CharInfo ();
    }

    override InfoType CastOp (InfoType other) {
	if (cast(CharInfo) other) return this;
	return null;
    }
    
    override int size () {
	return 1;
    }
    
}
