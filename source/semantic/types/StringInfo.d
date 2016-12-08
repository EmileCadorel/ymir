module semantic.types.StringInfo;
import syntax.Word, ast.Expression, syntax.Tokens;
import semantic.types.InfoType, utils.exception;
import semantic.types.StringUtils, ast.ParamList;
import semantic.types.CharInfo, semantic.types.IntInfo;
import ast.Var, semantic.types.UndefInfo;

class StringInfo : InfoType {

    this () {
	this._destruct = &StringUtils.InstDestruct;
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
	return null;
    }

    override InstCompS ParamOp () {
	return &StringUtils.InstParam;
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
    
    private InfoType Access (Expression expr) {
	if (cast(IntInfo) expr.info.type) {
	    auto ch = new CharInfo;
	    ch.lintInstMult = &StringUtils.InstAccessS;
	    ch.isConst = false;
	    return ch;
	}
	return null;
    }
    
    override string typeString () {
	return "string";
    }

    override InfoType clone () {
	return new StringInfo ();
    }

    override int size () {
	return 8;
    }
    
}

