module semantic.types.VoidInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression;

class VoidInfo : InfoType {
			        
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0) 
	    throw new NotATemplate (token);
	return new VoidInfo ();
    }

    override bool isSame (InfoType other) {
	return (cast (VoidInfo) other) !is null;
    }
    
    override InfoType clone () {
	return new VoidInfo ();
    }

    override InfoType cloneForParam () {
	return new VoidInfo ();
    }
    
    override string typeString () {
	return "void";
    }
    
}
