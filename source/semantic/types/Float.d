module semantic.types.FloatInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType, utils.exception;

class FloatInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new FloatInfo ();
    }

    override string typeString () {
	return "float";
    }

    override InfoType clone () {
	return new FloatInfo ();
    }

    override int size () {
	return -4;
    }
    
}
