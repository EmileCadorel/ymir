module semantic.types.RangeInfo;
import syntax.Word, ast.Expression, lint.LSize;
import semantic.types.InfoType;
import semantic.types.BoolInfo;
import syntax.Tokens, semantic.types.UndefInfo;
import ast.Var, semantic.types.RangeUtils;
import std.container;

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
    
    override InfoType BinaryOp (Word token, Expression right) {
	return null;
    }

    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
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

}


