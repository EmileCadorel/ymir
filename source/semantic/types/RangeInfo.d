module semantic.types.RangeInfo;
import syntax.Word, ast.Expression, lint.LSize;
import semantic.types.InfoType;
import semantic.types.BoolInfo;
import syntax.Tokens, semantic.types.UndefInfo;
import ast.Var, semantic.types.RangeUtils;
import std.container, syntax.Keys;
import semantic.types.LongInfo, semantic.types.IntInfo;
import semantic.types.FloatInfo, semantic.types.CharInfo;
import utils.exception, semantic.types.ClassUtils;

class RangeInfo : InfoType {

    private InfoType _content;
    
    this () {
	this._destruct = &RangeUtils.InstDestruct;
    }

    this (InfoType content) {
	this._destruct = &RangeUtils.InstDestruct;
	this._content = content;
    }

    InfoType content() {
	return this._content;
    }
    
    override InfoType clone () {
	auto ret = new RangeInfo (this._content.clone ());
	if (this._destruct is null) ret._destruct = null;
	return ret;
    }

    override InfoType cloneForParam () {
	return new RangeInfo (this._content.clone ());
    }

    override bool isSame (InfoType other) {
	if (auto _r = cast (RangeInfo) other) {
	    return _r._content.isSame (this._content);
	}
	return false;
    }

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast (Type) templates [0])) {
	    throw new UndefinedType (token, "prend un type primitif en template");
	} else {
	    auto type = templates [0].info.type;
	    if (!(cast (FloatInfo)  type) && !(cast (IntInfo) type) &&
		!(cast (CharInfo) type) && !(cast (LongInfo) type))
		throw new UndefinedType (token, "prend un type primitif en template");
	    auto arr = new RangeInfo (templates [0].info.type);
	    return arr;
	}
    }
    
    override InfoType BinaryOp (Word token, Expression right) {
	return null;
    }

    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	else if (token == Keys.IN) return In (left);
	return null;
    }

    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ret = this.clone ();
	    ret.lintInst = &RangeUtils.InstAffectRight;

	    return ret;
	}
	return null;
    }

    private InfoType In (Expression left) {
	if (this._content.isSame (left.info.type)) {
	    auto ret = new BoolInfo ();
	    final switch (this._content.size.id) {
	    case LSize.BYTE.id: ret.lintInst =  (&RangeUtils.InstIn!(LSize.BYTE)); break;
	    case LSize.SHORT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.SHORT)); break;
	    case LSize.INT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.INT)); break;
	    case LSize.LONG.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.LONG)); break;
	    case LSize.FLOAT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.FLOAT)); break;
	    case LSize.DOUBLE.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.DOUBLE)); break;
	    }
	    return ret;
	}
	return null;
    }
    
    override InfoType DotOp (Var var) {
	if (var.token.str == "fst") return Fst ();
	if (var.token.str == "scd") return Scd ();
	return null;
    }
    
    private InfoType Fst () {
	auto cst = this._content.clone ();
	final switch (cst.size.id) {
	case LSize.BYTE.id: cst.lintInst =  (&RangeUtils.InstFst!(LSize.BYTE)); break;
	case LSize.SHORT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.SHORT)); break;
	case LSize.INT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.INT)); break;
	case LSize.LONG.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.LONG)); break;
	case LSize.FLOAT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.FLOAT)); break;
	case LSize.DOUBLE.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.DOUBLE)); break;		    
	}
	return cst;
    }

    private InfoType Scd () {
	auto cst = this._content.clone ();
	final switch (cst.size.id) {
	case LSize.BYTE.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.BYTE)); break;
	case LSize.SHORT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.SHORT)); break;
	case LSize.INT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.INT)); break;
	case LSize.LONG.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.LONG)); break;
	case LSize.FLOAT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.FLOAT)); break;
	case LSize.DOUBLE.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.DOUBLE)); break;		    
	}
	return cst;
    }

    override InfoType ApplyOp (Array!Var vars) {
	if (vars.length != 1) return null;
	vars [0].info.type = this._content.clone ();
	vars [0].info.type.isConst = true;
	auto ret = this.clone ();
	ret.leftTreatment = &RangeUtils.InstApplyPreTreat;
	ret.lintInst = &RangeUtils.InstApply;
	return ret;
    }
    
    override string typeString () {
	return "range!(" ~ this._content.typeString ~ ")";
    }

    override LSize size () {
	return LSize.LONG;
    }

    static LSize sizeOf () {
	return LSize.INT;
    }
    
    override InfoType destruct () {
	if (this._destruct is null) return null;
	auto ret = this.clone ();
	ret.setDestruct (this._destruct);
	return ret;
    }

    override InfoType ParamOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstParam);
	return ret;
    }

    override InfoType ReturnOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstReturn);
	return ret;
    }

    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || this.isSame (other)) {
	    auto ra = this.clone ();
	    ra.lintInst = &RangeUtils.InstAffectRight;
	    return ra;
	}
	return null;
    }
    
}


