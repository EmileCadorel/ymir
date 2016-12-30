module semantic.types.PtrFuncInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.PtrFuncUtils, syntax.Keys;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;
import semantic.types.NullInfo, std.stdio;
import std.container, semantic.types.FunctionInfo, std.outbuffer;
import ast.ParamList, semantic.pack.Frame, semantic.types.StringInfo;

class PtrFuncInfo : InfoType {
    
    private Array!InfoType _params;
    private InfoType _ret;
    private ApplicationScore _score;
    
    this () {
    }

    override bool isSame (InfoType other) {
	auto ptr = cast (PtrFuncInfo) other;
	if (ptr is null) return false;
	else {
	    if (!this._ret.isSame (ptr._ret)) return false;
	    foreach (it ; 0 .. this._params.length) {
		if (!ptr._params [it].isSame (this._params [it]))
		    return false;
	    }
	    return true;
	}
    }

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length < 1)
	    throw new UndefinedType (token, "prend au moins un type en template");
	else {
	    auto ptr = new PtrFuncInfo ();
	    ptr._ret = templates [0].info.type;
	    if (templates.length > 1) {
		foreach (it ; 1 .. templates.length) {
		    ptr._params.insertBack (templates [it].info.type);
		}
	    }
	    return ptr;
	}
    }

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	if (token == Keys.IS) return Is (right);
	if (token == Keys.NOT_IS) return NotIs (right);
	return null;
    }
    
    override InfoType BinaryOpRight (Word token, Expression right) {
	if (token == Tokens.EQUAL) return AffectRight (right);
	if (token == Keys.IS) return Is (right);
	if (token == Keys.NOT_IS) return NotIs (right);
	return null;
    }

    private InfoType Affect (Expression right) {
	if (auto fun = cast (FunctionInfo) right.info.type) {
	    auto score = fun.CallOp (right.token, this._params);
	    if (score is null || !score.ret.isSame (this._ret)) return null;
	    auto ret = cast (PtrFuncInfo) this.clone ();
	    ret._score = score;
	    ret.lintInst = &PtrFuncUtils.InstAffect;
	    ret.rightTreatment = &PtrFuncUtils.InstConstFunc;
	    return ret;
	} else if (cast (NullInfo) right.info.type) {
	    auto ret = this.clone ();
	    ret.lintInst = &PtrFuncUtils.InstAffectNull;
	    return ret;
	}
	return null;
    }
    
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ret = new PtrFuncInfo ();
	    ret._ret = this._ret.clone ();
	    foreach (it ; this._params)
		ret._params.insertBack (it.clone ());
	    ret.lintInst = &PtrFuncUtils.InstAffect;
	    return ret;
	}
	return null;
    }

    private InfoType Is (Expression right) {
	if (cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstIs;
	    return ret;
	} else if (cast (PtrFuncInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstIs;
	    return ret;
	}
	return null;
    }

    private InfoType NotIs (Expression right) {
	if (cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstNotIs;
	    return ret;
	} else if (cast (PtrFuncInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstNotIs;
	    return ret;
	}
	return null;
    }
    
    override InfoType clone () {
	auto aux = new PtrFuncInfo ();
	foreach (it ; this._params) {
	    aux._params.insertBack (it.clone ());	    
	}
	aux._ret = this._ret.clone ();
	aux._score = this._score;
	return aux;
    }

    override InfoType cloneForParam () {
	auto aux = new PtrFuncInfo ();
	foreach (it ; this._params) {
	    aux._params.insertBack (it.clone ());	    
	}
	aux._ret = this._ret.clone ();
	return aux;
    }

    override LSize size () {
	return LSize.LONG;
    }

    override ApplicationScore CallOp (Word token, ParamList params) {
	if (params.params.length != this._params.length) {
	    return null;
	}
	
	auto score = new ApplicationScore (token);
	foreach (it ; 0 .. this._params.length) {
	    InfoType info = this._params [it];	    
	    auto type = params.params [it].info.type.CompOp (info);
	    if (type && type.isSame(info)) {
		score.score += Frame.SAME;
		score.treat.insertBack (type);
	    } else if (type !is null) {
		score.score += Frame.AFF;
		score.treat.insertBack (type);
	    } else return null;
	}
	
	auto ret = this._ret.cloneForParam ();
	score.dyn = true;
	score.ret = ret;
	return score;
    }
    
    override InfoType CompOp (InfoType other) {
	if (other.isSame (this) || cast (UndefInfo) other) {
	    auto ptr = this.clone ();
	    ptr.lintInst = &PtrFuncUtils.InstAffect;
	    return ptr;
	}
	return null;
    }

    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") {
	    auto str = new StringInfo ();
	    str.lintInst = &PtrFuncUtils.StringOf;
	    str.leftTreatment = &PtrFuncUtils.GetStringOf;
	    return str;
	}
	return null;
    }    

    override string typeString () {
	auto buf = new OutBuffer ();
	buf.write ("function(");
	foreach (it ; this._params) {
	    buf.write (it.typeString);
	    if (it != this._params [$ - 1])
		buf.write (",");
	}
	buf.writef ("):%s", this._ret.typeString);
	return buf.toString ();
    }

    ApplicationScore score () {
	return this._score;
    }
    
}
