module semantic.types.BoolInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType, utils.exception;

class BoolInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new BoolInfo ();
    }

    override string typeString () {
	return "bool";
    }

    override InfoType clone () {
	return new BoolInfo ();
    }

    override int size () {
	return 1;
    }
    
}
