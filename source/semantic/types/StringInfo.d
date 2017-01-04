module semantic.types.StringInfo;
import lint.LSize;
import syntax.Word, ast.Expression, syntax.Tokens;
import semantic.types.InfoType, utils.exception;
import semantic.types.StringUtils, ast.ParamList;
import semantic.types.CharInfo, semantic.types.IntInfo;
import ast.Var, semantic.types.UndefInfo, semantic.types.ArrayInfo;
import semantic.types.RefInfo, semantic.types.ClassUtils;
import semantic.types.LongInfo, std.container;
import semantic.types.ArrayUtils;
import semantic.types.NullInfo, semantic.types.BoolInfo;
import syntax.Keys;


class StringInfo : InfoType {

    this () {
	this._destruct = &StringUtils.InstDestruct;
    }

    override InfoType CompOp (InfoType other) {
	if (cast (StringInfo) other || cast (UndefInfo) other) {
	    auto ret = new StringInfo ();
	    ret.lintInstS.insertBack (&StringUtils.InstComp);
	    ret.lintInst = &ClassUtils.InstAffectRight;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (cast (StringInfo) _ref.content  && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS.insertBack (&StringUtils.InstAddr);
		return aux;
	    }
	}
	return null;
    }
    
    override bool isSame (InfoType other) {
	return (cast (StringInfo) other) !is null;
    }
    
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new StringInfo ();
    }

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	else if (token == Tokens.PLUS) return Plus (right);
	else if (token == Tokens.PLUS_AFF) return PlusAff (right);
	else if (token == Keys.IS) return Is (right);
	else if (token == Keys.NOT_IS) return NotIs (right);
	else return null;
    }

    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	else return null;
    }

    private InfoType Affect (Expression right) {
	if (cast(StringInfo)right.info.type) {
	    auto str = new StringInfo ();
	    str.lintInst = &ClassUtils.InstAffect;
	    return str;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new StringInfo ();
	    ret.lintInst = &ClassUtils.InstAffectNull;
	    return ret;	    
	}
	return null;
    }    

    private InfoType Is (Expression right) {
	if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstIs;
	    return ret;
	}
	return null;
    }

    private InfoType NotIs (Expression right) {
	if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstNotIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstNotIs;
	    return ret;
	}
	return null;
    }    
    
    private InfoType PlusAff (Expression right) {
	if (cast (StringInfo) right.info.type) {
	    auto str = new StringInfo ;
	    str.lintInst = &StringUtils.InstPlusAffect;
	    return str;
	}
	return null;
    }
    
    private InfoType Plus (Expression right) {
	if (cast (StringInfo) right.info.type) {
	    auto str = new StringInfo ();
	    str.lintInst = &StringUtils.InstPlus;
	    return str;
	}
	return null;
    }
    
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto str = new StringInfo ();
	    str.lintInst = &ClassUtils.InstAffectRight;
	    return str;
	}
	return null;
    }
    
    override InfoType CastOp (InfoType info) {
	if (cast (StringInfo)info) return this;
	auto type = cast (ArrayInfo) info;
	if (type && cast (CharInfo) type.content) {
	    auto other = new ArrayInfo (new CharInfo);
	    other.setDestruct (null);
	    other.lintInstS.insertBack (&StringUtils.InstCastArray);
	    return other;
	}
	return null; 
    }

    override InfoType ApplyOp (Array!Var vars) {
	if (vars.length != 1) return null;
	vars [0].info.type = new RefInfo (new CharInfo ());
	vars [0].info.type.isConst = this.isConst;
	auto ret = new ArrayInfo (new CharInfo ());
	ret.leftTreatment = &ArrayUtils.InstApplyPreTreat;
	ret.lintInst = &ArrayUtils.InstApply;
	return ret;
    }
    
    override InfoType AccessOp (Word token, ParamList params) {
	if (params.params.length == 1) {
	    return Access (params.params [0]);
	} else {
	    return null;
	}
    }

    override InfoType DotOp (Var var) {       
	if (var.token.str == "nbRef") return NbRef ();
	if (var.token.str == "length") return Length ();
	else if (var.token.str == "dup") return Dup ();
	else if (var.token.str == "typeid") return StringOf ();
	return null;
    }

    override InfoType ParamOp () {
	auto str = new StringInfo ();
	str.lintInstS.insertBack (&ClassUtils.InstParam);
	return str;
    }

    override InfoType ReturnOp () {
	auto str = new StringInfo ();
	str.lintInstS.insertBack (&ClassUtils.InstReturn);
	return str;
    }
    
    private InfoType NbRef () {
	auto _int = new IntInfo;
	_int.lintInst = &StringUtils.InstNbRef;
	return _int;
    }
    
    private InfoType Length () {
	auto _int = new LongInfo ();
	_int.lintInst = &StringUtils.InstLength ;
	return _int;
    }

    private InfoType Dup () {
	auto str = new StringInfo ();
	str.lintInst = &StringUtils.InstDup;
	str.isConst = false;
	return str;
    }
    
    private InfoType StringOf () {
	auto str = new StringInfo;
	str.lintInst = &StringUtils.StringOf;
	str.leftTreatment = &StringUtils.GetStringOf;
	return str;
    }
    
    private InfoType Access (Expression expr) {
	if (cast(IntInfo) expr.info.type || cast (LongInfo) expr.info.type) {
	    auto ch = new CharInfo;
	    ch.lintInstMult = &StringUtils.InstAccessS;
	    ch.isConst = false;
	    ch.setDestruct (null);
	    return ch;
	}
	return null;
    }
    
    override string typeString () {
	return "string";
    }

    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	return "s";
    }
    
    override InfoType clone () {
	auto ret = new StringInfo ();
	if (this._destruct is null) ret._destruct = null;
	return ret;
    }

    override InfoType cloneForParam () {
	return new StringInfo ();
    }

    override LSize size () {
	return LSize.LONG;
    }
    
    override InfoType destruct () {
	if (this._destruct is null) return null;
	auto ret = new StringInfo ();
	ret.setDestruct (this._destruct);
	return ret;
    }

}

