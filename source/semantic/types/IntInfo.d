module semantic.types.IntInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType;
import syntax.Tokens;

class IntInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0) 
	    throw new NotATemplate (token);
	return new IntInfo ();
    }

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	return null;
    }

    InfoType Affect (Expression right) {
	if (cast(IntInfo)right.info.type !is null) return new IntInfo ();
	return null;
    }
    
    override string typeString () {
	return "int";
    }

    override InfoType clone () {
	return new IntInfo ();
    }    
    
}
