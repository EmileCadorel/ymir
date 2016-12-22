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

    override InfoType clone () {
	return new UndefInfo ();
    }

    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") {
	    auto str = new StringInfo;
	    str.lintInst = &PtrUtils.StringOf;
	    str.leftTreatment = &PtrUtils.GetStringOf;
	    return str;
	}
	return null;
    }

    
    override InfoType cloneForParam () {
	assert (false, "Pas normal cette histoire");
    }
    
}
