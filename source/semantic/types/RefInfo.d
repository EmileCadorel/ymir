module semantic.types.RefInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.RefUtils, syntax.Keys;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;
import ast.ParamList, semantic.types.StructInfo;

class RefInfo : InfoType {

    private InfoType _content = null;
    
    this () {
	this._content = new VoidInfo ();
    }

    this (InfoType content) {
	this._content = content;
    }

    InfoType content () {
	return this._content;
    }
    
    override bool isSame (InfoType other) {
	auto ptr = cast (RefInfo) other;
	if (ptr is null) return false;
	if (this._content is ptr.content) return true;
	return ptr.content.isSame (this._content);
    }

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast (Type) templates [0]))
	    if (auto _cst = cast (StructCstInfo) templates [0].info.type) {
		return new RefInfo (_cst.create (templates [0].token, []));
	    } else
		throw new UndefinedType (token, "prend un type en template");
	else return new RefInfo (templates [0].info.type);	
    }

    override InfoType BinaryOp (Word token, Expression right) {
	auto aux = this._content.BinaryOp (token, right);
	if (aux !is null) {
	    if (this._content.size == LSize.BYTE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.BYTE);
	    else if (this._content.size == LSize.SHORT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.SHORT);
	    else if (this._content.size == LSize.INT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.INT);
	    else if (this._content.size == LSize.LONG)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.LONG);
	    else if (this._content.size == LSize.FLOAT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.FLOAT);
	    else if (this._content.size == LSize.DOUBLE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.DOUBLE);	
	    return aux;
	}
	return null;
    }

    override InfoType BinaryOpRight (Word token, Expression right) {
	auto aux = this._content.BinaryOpRight (token, right);
	if (aux !is null) {
	    if (this._content.size == LSize.BYTE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.BYTE);
	    else if (this._content.size == LSize.SHORT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.SHORT);
	    else if (this._content.size == LSize.INT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.INT);
	    else if (this._content.size == LSize.LONG)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.LONG);
	    else if (this._content.size == LSize.FLOAT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.FLOAT);
	    else if (this._content.size == LSize.DOUBLE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.DOUBLE);	
	    return aux;
	}   
	return null;
    }

    override InfoType AccessOp (Word token, ParamList params) {
	auto aux = this._content.AccessOp (token, params);
	if (aux !is null) {
	    if (this._content.size == LSize.BYTE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.BYTE);
	    else if (this._content.size == LSize.SHORT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.SHORT);
	    else if (this._content.size == LSize.INT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.INT);
	    else if (this._content.size == LSize.LONG)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.LONG);
	    else if (this._content.size == LSize.FLOAT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.FLOAT);
	    else if (this._content.size == LSize.DOUBLE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.DOUBLE);	
	    return aux;
	}
	return null;	
    }
    
    override InfoType DotOp (Var var) {
	auto aux = this._content.DotOp (var);
	if (aux !is null) {
	    if (this._content.size == LSize.BYTE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.BYTE);
	    else if (this._content.size == LSize.SHORT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.SHORT);
	    else if (this._content.size == LSize.INT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.INT);
	    else if (this._content.size == LSize.LONG)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.LONG);
	    else if (this._content.size == LSize.FLOAT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.FLOAT);
	    else if (this._content.size == LSize.DOUBLE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.DOUBLE);
	    return aux;
	}
	return null;	
    }

    override InfoType ParamOp () {
	return null;
    }

    override InfoType ReturnOp () {
	return null;
    }
        
    override InfoType clone () {
	return new RefInfo (this._content.clone ());
    }

    override InfoType cloneForParam () {
	return new RefInfo (this._content.cloneForParam ());
    }

    override InfoType CompOp (InfoType other) {
	auto ptr = cast (RefInfo) other;
	if (ptr && ptr.content.isSame (this._content)) {
	    auto rf = this.clone ();
	    rf.lintInst = &RefUtils.InstAffect;
	    return rf;
	} else {
	    auto aux = this._content.CompOp (other);	    
	    if (aux !is null) {
		if (this._content.size == LSize.BYTE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.BYTE);
		else if (this._content.size == LSize.SHORT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.SHORT);
		else if (this._content.size == LSize.INT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.INT);
		else if (this._content.size == LSize.LONG)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.LONG);
		else if (this._content.size == LSize.FLOAT)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.FLOAT);
		else if (this._content.size == LSize.DOUBLE)  aux.leftTreatment = &RefUtils.InstUnref!(LSize.DOUBLE);
		return aux;
	    }
	    return null;
	}
    }
    
    override string typeString () {
	return "ref!" ~ this._content.typeString ();
    }

    override ref bool isConst () {
	return this._content.isConst;
    }

    override void setDestruct (InstCompS s) {
	this._content.setDestruct (s);
    }
    
    override bool isDestructible () {
	return this._content.isDestructible ();
    }
    
    override InfoType destruct () {
	return null;
    }
    
    override LSize size () {
	return LSize.LONG;
    }
    

    
}
