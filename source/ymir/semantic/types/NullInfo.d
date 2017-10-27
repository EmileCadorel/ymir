module ymir.semantic.types.NullInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

/**
 Classe d'information du type null.
 */
class NullInfo : InfoType {

    this () {
	super (true);
    }
    
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

    override Expression toYmir () {
	return null;
    }
    
    /**
     Operateur d'accés au attribut.
     Params:
     var = l'attribut demandé.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.templates.length != 0) return null;
	if (var.token.str == "typeid") {
	    auto str = new StringInfo (true);
	    str.value = new StringValue (this.typeString);
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
	} else if (auto arr = cast (ArrayInfo) other) {
	    auto ret = other.clone ();
	    ret.leftTreatment = &ArrayUtils.InstCastFromNull;
	    return ret;
	} else if (cast (StringInfo) other) {
	    auto ret = other.clone ();
	    ret.leftTreatment = &ArrayUtils.InstCastFromNull;
	    return ret;
	} else if (cast (PtrInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (PtrFuncInfo) other) {
	    auto ret = other.clone ();
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (NullInfo) other) {
	    return this;
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
    override string innerTypeString () {
	return "null";
    }

    /**
     Returns: le nom du type.
     */
    override string simpleTypeString () {
	return "n";
    }
    
}
