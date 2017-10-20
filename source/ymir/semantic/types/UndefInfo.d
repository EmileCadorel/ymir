module ymir.semantic.types.UndefInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

class UndefInfo : InfoType {

    this () {
	super (true);
    }
    
    override bool isSame (InfoType) {
	return false;
    }
    
    override string innerTypeString () {
	return "undef";
    }

    override string simpleTypeString () {
	return "u";
    }
    
    override InfoType clone () {
	return new UndefInfo ();
    }

    override InfoType DotOp (Var var) {
	if (var.templates.length != 0) return null;
	if (var.token.str == "typeid") {
	    auto str = new StringInfo  (true);
	    str.value = new StringValue (this.typeString);
	    return str;
	}
	return null;
    }
    
    override InfoType cloneForParam () {
	return new UndefInfo ();
    }
    
}
