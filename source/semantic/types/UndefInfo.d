module semantic.types.UndefInfo;
import semantic.types.InfoType, utils.exception;
import ast.Var, semantic.types.StringInfo;
import semantic.types.PtrUtils;

class UndefInfo : InfoType {

    override bool isSame (InfoType) {
	return false;
    }
    
    override string typeString () {
	return "undef";
    }

    override string simpleTypeString () {
	return "u";
    }
    
    override InfoType clone () {
	return new UndefInfo ();
    }

    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") {
	    auto str = new StringInfo;
	    str.value = new StringValue (this.typeString);
	    return str;
	}
	return null;
    }
    
    override InfoType cloneForParam () {
	return new UndefInfo ();
    }
    
}
