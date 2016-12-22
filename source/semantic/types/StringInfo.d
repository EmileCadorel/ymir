module semantic.types.StringInfo;
import lint.LSize;
import syntax.Word, ast.Expression, syntax.Tokens;
import semantic.types.InfoType, utils.exception;
import semantic.types.StringUtils, ast.ParamList;
import semantic.types.CharInfo, semantic.types.IntInfo;
import ast.Var, semantic.types.UndefInfo, semantic.types.ArrayInfo;
import semantic.types.RefInfo, semantic.types.ClassUtils;

class StringInfo : InfoType {

    this () {
	this._destruct = &StringUtils.InstDestruct;
    }

    override InfoType CompOp (InfoType other) {
	if (cast (StringInfo) other) {
	    other.lintInstS = &StringUtils.InstComp;
	    return other;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (cast (StringInfo) _ref.content  && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS = &StringUtils.InstAddr;
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
	else return null;
    }

    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	else return null;
    }

    private InfoType Affect (Expression right) {
	if (cast(StringInfo)right.info.type) {
	    auto str = new StringInfo ();
	    str.lintInst = &StringUtils.InstAffect;
	    return str;
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
	    str.lintInst = &StringUtils.InstAffectRight;
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
	    other.lintInstS = &StringUtils.InstCastArray;
	    return other;
	}
	return null; 
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
	str.lintInstS = &ClassUtils.InstParam;
	return str;
    }

    override InfoType ReturnOp () {
	auto str = new StringInfo ();
	str.lintInstS = &ClassUtils.InstReturn;
	return str;
    }
    
    private InfoType NbRef () {
	auto _int = new IntInfo;
	_int.lintInst = &StringUtils.InstNbRef;
	return _int;
    }
    
    private InfoType Length () {
	auto _int = new IntInfo ();
	_int.lintInst = &StringUtils.InstLength ;
	return _int;
    }

    private InfoType Dup () {
	auto str = new StringInfo ();
	str.lintInst = &StringUtils.InstDup;
	return str;
    }
    
    private InfoType StringOf () {
	auto str = new StringInfo;
	str.lintInst = &StringUtils.StringOf;
	str.leftTreatment = &StringUtils.GetStringOf;
	return str;
    }
    
    private InfoType Access (Expression expr) {
	if (cast(IntInfo) expr.info.type) {
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

