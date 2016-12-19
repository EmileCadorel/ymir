module semantic.types.PtrInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.PtrUtils, syntax.Keys;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;

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
	else if (token == Tokens.PLUS) return Plus (right);
	else if (token == Tokens.MINUS) return Sub (right);
	else if (token == Keys.IS) return Is (right);
	else if (token == Keys.NOT_IS) return NotIs (right);
	return null;
    }

    override InfoType BinaryOpRight (Word token, Expression right) {
	if (token == Tokens.EQUAL) return AffectRight (right);
	if (token == Tokens.PLUS) return PlusRight (right);
	else if (token == Tokens.MINUS) return SubRight (right);
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
	} else if (type && cast (VoidInfo) this._content) {
	    this._content = type.content.clone ();
	    auto ret = new PtrInfo (this._content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (type && cast (VoidInfo) type.content) {
	    auto ret = new PtrInfo (type.content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	}
	return null;
    }

    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ret = new PtrInfo (this._content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	}
	return null;
    }
    
    private InfoType Plus (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto ptr = new PtrInfo (this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.BYTE, Tokens.PLUS);
	    else if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.SHORT, Tokens.PLUS);
	    else if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.INT, Tokens.PLUS);
	    else if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOp !(LSize.LONG, Tokens.PLUS);
	    else if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.FLOAT, Tokens.PLUS);
	    else if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.DOUBLE, Tokens.PLUS);
	    else return null;
	    return ptr;
	}
	return null;
    }

    private InfoType Sub (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto ptr = new PtrInfo (this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.BYTE, Tokens.MINUS);
	    else if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.SHORT, Tokens.MINUS);
	    else if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.INT, Tokens.MINUS);
	    else if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOp !(LSize.LONG, Tokens.MINUS);
	    else if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.FLOAT, Tokens.MINUS);
	    else if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.DOUBLE, Tokens.MINUS);
	    else return null;
	    return ptr;
	}
	return null;
    }
    
    private InfoType PlusRight (Expression left) {
	if (cast (IntInfo) left.info.type) {
	    auto ptr = new PtrInfo (this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.BYTE, Tokens.PLUS);
	    else if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.SHORT, Tokens.PLUS);
	    else if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.INT, Tokens.PLUS);
	    else if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.LONG, Tokens.PLUS);
	    else if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.FLOAT, Tokens.PLUS);
	    else if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.DOUBLE, Tokens.PLUS);
	    else return null;
	    return ptr;
	}
	return null;
    }

    private InfoType SubRight (Expression left) {
	if (cast (IntInfo) left.info.type) {
	    auto ptr = new PtrInfo (this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.BYTE, Tokens.MINUS);
	    if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.SHORT, Tokens.MINUS);
	    if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.INT, Tokens.MINUS);
	    if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.LONG, Tokens.MINUS);
	    if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.FLOAT, Tokens.MINUS);
	    if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.DOUBLE, Tokens.MINUS);
	    return ptr;
	}
	return null;
    }

    private InfoType Is (Expression right) {
	if (cast (PtrInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrUtils.InstIs;
	    return ret;
	} 
	return null;
    }

    private InfoType NotIs (Expression right) {
	if (cast (PtrInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrUtils.InstNotIs;
	    return ret;
	} 
	return null;
    }    
    
    private InfoType Unref () {
	if (cast (UndefInfo) this._content) return null;
	else if (cast (VoidInfo) this._content) return null;
	auto ret = this._content.clone ();
	if (this._content.size == LSize.BYTE)  ret.lintInstS = &PtrUtils.InstUnref!(LSize.BYTE);
	else if (this._content.size == LSize.SHORT)  ret.lintInstS = &PtrUtils.InstUnref!(LSize.SHORT);
	else if (this._content.size == LSize.INT)  ret.lintInstS = &PtrUtils.InstUnref!(LSize.INT);
	else if (this._content.size == LSize.LONG)  ret.lintInstS = &PtrUtils.InstUnref!(LSize.LONG);
	else if (this._content.size == LSize.FLOAT)  ret.lintInstS = &PtrUtils.InstUnref!(LSize.FLOAT);
	else if (this._content.size == LSize.DOUBLE)  ret.lintInstS = &PtrUtils.InstUnref!(LSize.DOUBLE);
	else return null;
	ret.isConst = false;
	ret.setDestruct (null);
	return ret;
    }

    override InfoType DotOp (Var var) {
	if (var.isType) {
	    auto type = var.asType ();
	    auto ret = type.info.type;
	    if (ret.size == LSize.BYTE)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.BYTE);
	    else if (ret.size == LSize.SHORT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.SHORT);
	    else if (ret.size == LSize.INT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.INT);
	    else if (ret.size == LSize.LONG)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.LONG);
	    else if (ret.size == LSize.FLOAT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.FLOAT);
	    else if (ret.size == LSize.DOUBLE)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.DOUBLE);
	    else return null;
	    ret.isConst = false;
	    return ret;
	} else if (var.token.str == "init") {
	    auto type = this.clone ();
	    type.lintInst = &PtrUtils.InstNull;
	    return type;
	}
	return null;  
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

    override InfoType cloneForParam () {
	return clone ();
    }
    
    override InfoType CastOp (InfoType other) {
	auto type = cast (PtrInfo) other;
	if (type && type.content.isSame (this._content)) {
	    return this;
	} else if (type) {
	    auto ptr = new PtrInfo (type.content.clone ());
	    ptr.lintInstS = &PtrUtils.InstCast;
	    return ptr;
	}
	return null;
    }
    
    override string typeString () {
	if (this._content is null) {
	    return "ptr!void";
	} else return "ptr!" ~ this._content.typeString ();
    }

    override LSize size () {
	return LSize.LONG;
    }
    
}
