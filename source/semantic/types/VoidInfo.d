module semantic.types.VoidInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression;
import ast.Var, semantic.types.PtrUtils;
import semantic.types.StringInfo;

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

    override InfoType DotOp (Var var) {
	if (var.templates.length != 0) return null;
	if (var.token.str == "typeid") {
	    auto str = new StringInfo;
	    str.value = new StringValue (this.typeString);
	    return str;
	}
	return null;
    }
    
    override InfoType cloneForParam () {
	return new VoidInfo ();
    }
    
    override string typeString () {
	return "void";
    }

    override string simpleTypeString () {
	return "v";
    }
    
}
