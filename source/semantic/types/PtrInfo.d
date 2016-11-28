module semantic.types.PtrInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;

class PtrInfo : InfoType {

    private InfoType _content = null;
    
    this () {}

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast(Type)templates[0]))
	    throw new UndefinedType (token, "prend un type en template");
	else {
	    auto ptr = new PtrInfo ();
	    ptr._content = templates[0].info.type;
	    return ptr;
	}
	
    }

    ref InfoType content () {
	return this._content;
    }
    
    override InfoType clone () {
	if (this._content is null)
	    return new PtrInfo ();
	else {
	    auto aux = new PtrInfo ();
	    aux._content = this._content.clone ();
	    return aux;
	}
    }
    
    override string typeString () {
	if (this._content is null) {
	    return "ptr!void";
	} else return "ptr!" ~ this._content.typeString ();
    }

    override int size () {
	return 8;
    }
    
}
