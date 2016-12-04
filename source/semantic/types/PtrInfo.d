module semantic.types.PtrInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.PtrUtils;


class PtrInfo : InfoType {

    private InfoType _content = null;
    
    this () {
	this._content = new VoidInfo ();
    }

    this (InfoType content) {
	this._content = content;
    }   

    override bool isSame (InfoType other) {
	auto ptr = cast (PtrInfo) other;
	if (ptr is null) return false;
	if (this._content is ptr.content) return true;
	return ptr.content.isSame (this._content);
    }
    
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast(Type)templates[0]))
	    throw new UndefinedType (token, "prend un type en template");
	else {
	    auto ptr = new PtrInfo (templates [0].info.type);
	    return ptr;
	}
	
    }

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	return null;
    }

    override InfoType UnaryOp (Word op) {
	if (op == Tokens.STAR) return Unref ();
	return null;
    }
    
    private InfoType Affect (Expression right) {
	auto type = cast (PtrInfo) right.info.type;
	if (type !is null && type.content.isSame (this._content)) {
	    auto ret = new PtrInfo (this._content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect ;
	    return ret;
	}
	return null;
    }

    private InfoType Unref () {
	auto ret = this._content.clone ();
	if (this._content.size == 1)  ret.lintInstS = &PtrUtils.InstUnref!(1);
	if (this._content.size == 2)  ret.lintInstS = &PtrUtils.InstUnref!(2);
	if (this._content.size == 4)  ret.lintInstS = &PtrUtils.InstUnref!(4);
	if (this._content.size == 8)  ret.lintInstS = &PtrUtils.InstUnref!(8);
	if (this._content.size == -8)  ret.lintInstS = &PtrUtils.InstUnref!(-8);
	if (this._content.size == -4)  ret.lintInstS = &PtrUtils.InstUnref!(-4);
	ret.isConst = false;
	return ret;
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
