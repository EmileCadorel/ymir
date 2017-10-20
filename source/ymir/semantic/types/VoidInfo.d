module ymir.semantic.types.VoidInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

class VoidInfo : InfoType {

    this () {
	super (true);
    }
    
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
	    auto str = new StringInfo (true);
	    str.value = new StringValue (this.typeString);
	    return str;
	}
	return null;
    }
    
    override InfoType cloneForParam () {
	return new VoidInfo ();
    }
    
    override string innerTypeString () {
	return "void";
    }

    override string simpleTypeString () {
	return "v";
    }
    
}
