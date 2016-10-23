module semantic.types.IntInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType;

class IntInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0) 
	    throw new NotATemplate (token);
	return new IntInfo ();
    }

    
}
