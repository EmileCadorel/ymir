module semantic.types.NullInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression;
import ast.Var, semantic.types.PtrUtils;
import semantic.types.StringInfo;
import semantic.types.ArrayInfo;
import semantic.types.PtrInfo;
import semantic.types.PtrFuncInfo;
import semantic.types.StructInfo;
import semantic.types.RangeInfo;

class NullInfo : InfoType {
			        
    override bool isSame (InfoType other) {
	return (cast (NullInfo) other) !is null;
    }
    
    override InfoType clone () {
	return new NullInfo ();
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
    
    override InfoType CompOp (InfoType other) {
	if (cast (StructInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (ArrayInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (StringInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (PtrInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (PtrFuncInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (RangeInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	}
	return null;
    }

    override InfoType cloneForParam () {
	return new NullInfo ();
    }
    
    override string typeString () {
	return "null";
    }
    
}
