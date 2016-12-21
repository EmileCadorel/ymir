module semantic.types.ArrayInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.ArrayUtils, syntax.Keys;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo, semantic.types.PtrInfo;
import ast.ParamList, semantic.types.StringInfo, semantic.types.CharInfo;
import lint.LSize, semantic.types.ClassUtils;

class ArrayInfo : InfoType {

    private InfoType _content = null;

    this () {
	this._content = new VoidInfo ();
	this._destruct = &ArrayUtils.InstDestruct;
    }

    this (InfoType content) {
	this._content = content;
	this._destruct = &ArrayUtils.InstDestruct;
    }

    InfoType content () {
	return this._content;
    }
    
    override bool isSame (InfoType other) {
	auto arr = cast (ArrayInfo) other;
	if (arr is null) return false;
	if (this._content is arr._content) return true;
	return arr._content.isSame (this._content);
    }

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast (Type) templates [0])) {
	    throw new UndefinedType (token, "prend un type en template");
	} else {
	    auto arr = new ArrayInfo (templates [0].info.type);
	    return arr;
	}
    }

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	else if (token == Tokens.PLUS) return Plus (right);
	return null;
    }

    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	return null;
    }

       
    private InfoType Plus (Expression right) {
	auto arr = cast (ArrayInfo) right.info.type;
	if (arr && arr._content.isSame (this._content) && !cast(VoidInfo) this._content) {
	    auto str = new ArrayInfo (this._content.clone ());
	    switch (this._content.size.id) {
	    case 1: str.lintInst = &ArrayUtils.InstPlus !(LSize.BYTE); break;
	    case 3: str.lintInst = &ArrayUtils.InstPlus !(LSize.INT); break;
	    case 4: str.lintInst = &ArrayUtils.InstPlus !(LSize.LONG); break;
	    default : assert (false, "TODO");
	    }
	    return str;
	}
	return null;
    }

    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto arr = new ArrayInfo (this._content.clone ());
	    arr.lintInst = &ArrayUtils.InstAffectRight;
	    return arr;
	}
	return null;
    }

    override InfoType ParamOp () {
	auto str = new ArrayInfo (this._content.clone);
	str.lintInstS = &ClassUtils.InstParam;
	return str;
    }
    
    override InfoType ReturnOp () {
	auto str = new ArrayInfo (this._content.clone);
	str.lintInstS = &ClassUtils.InstReturn;
	return str;
    }


    override InfoType AccessOp (Word token, ParamList params) {
	if (params.params.length == 1) {
	    return Access (params.params [0]);
	}
	return null;
    }
    
    override InfoType DotOp (Var var) {
	if (var.token.str == "length") return Length;
	return null;
    }

    private InfoType Length () {
	if (cast (VoidInfo) this._content) return null; 
	auto elem = new IntInfo ();
	elem.lintInst = &ArrayUtils.InstLength;
	return elem;
    }

    private InfoType Access (Expression expr) {
	if (cast (IntInfo) expr.info.type) {
	    auto ch = this._content.clone ();
	    switch (ch.size.id) {
	    case 1: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.BYTE); break;
	    case 2: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.SHORT); break;
	    case 3: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.INT); break;
	    case 4: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.LONG); break;
	    case 5: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.FLOAT); break;
	    case 6: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.DOUBLE); break;
	    default : assert (false);
	    }
	    ch.isConst = false;
	    ch.setDestruct (null);
	    return ch;
	}
	return null;
    }
    
    private InfoType Affect (Expression left) {
	auto type = cast (ArrayInfo) left.info.type;
	if (type  && type._content.isSame (this._content)) {
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ArrayUtils.InstAffect;
	    return ret;
	} else if (type && cast (VoidInfo) this._content) {
	    this._content = type._content.clone ();
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ArrayUtils.InstAffect;
	    return ret;
	} else {
	    auto ptr = cast (PtrInfo) left.info.type;
	    if (ptr && cast (VoidInfo) ptr.content) {
		auto ret = new ArrayInfo (ptr.content.clone ());
		ret.lintInst = &ArrayUtils.InstAffectNull;
		return ret;
	    }
	}
	return null;
    }

    override InfoType clone () {
	auto ret = new ArrayInfo (this._content.clone ());
	if (this._destruct is null) ret._destruct = null;
	return ret;
    }
   
    override InfoType cloneForParam () {
	return new ArrayInfo (this._content.clone ());
    }

    override InfoType CastOp (InfoType other) {
	auto type = cast (ArrayInfo) other;
	if (type && type.content.isSame (this._content)) {
	    return this;
	} else if (cast(StringInfo) other && cast(CharInfo) this._content) {
	    auto _other = new StringInfo ();
	    _other.lintInstS = &ArrayUtils.InstCastString;
	    _other.setDestruct (null);
	    return _other;
	}
	return null;	
    }

    override InfoType CompOp (InfoType other) {
	auto type = cast (ArrayInfo) other;
	if (type && type.content.isSame (this._content)) {
	    return other;
	}
	return null;
    }
    
    override string typeString () {
	return "array!" ~ this._content.typeString ();
    }

    override LSize size () {
	return LSize.LONG;
    }

    override InfoType destruct () {
	auto ret = this.clone ();
	ret.setDestruct (this._destruct);
	return ret;
    }

    
}
