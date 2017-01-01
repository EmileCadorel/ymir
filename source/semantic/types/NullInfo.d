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

/**
 Classe d'information du type null.
 */
class NullInfo : InfoType {

    /**
     Params:
     other = le deuxieme type.
     Returns: other est de type null ?
     */
    override bool isSame (InfoType other) {
	return (cast (NullInfo) other) !is null;
    }

    /**
     Returns: un nouvelle instance de null.
     */
    override InfoType clone () {
	return new NullInfo ();
    }

    /**
     Operateur d'accés au attribut.
     Params:
     var = l'attribut demandé.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") {
	    auto str = new StringInfo;
	    str.lintInst = &PtrUtils.StringOf;
	    str.leftTreatment = &PtrUtils.GetStringOf;
	    return str;
	}
	return null;
    }
    
    /**
     Operateur de cast automatique.
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
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

    /**
     Returns: un nouvelle instance de null.
     */
    override InfoType cloneForParam () {
	return new NullInfo ();
    }

    /**
     Returns: le nom du type null.
     */
    override string typeString () {
	return "null";
    }
    
}
