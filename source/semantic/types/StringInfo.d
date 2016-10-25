module semantic.types.StringInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType;

class StringInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new StringInfo ();
    }

    override string typeString () {
	return "string";
    }

    override InfoType clone () {
	return new StringInfo ();
    }
    
}

