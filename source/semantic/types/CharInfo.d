module semantic.types.CharInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType, utils.exception;
import semantic.types.CharUtils, syntax.Tokens;
import semantic.types.BoolInfo, semantic.types.IntInfo;
import semantic.types.UndefInfo, lint.LSize;
import semantic.types.StringInfo, ast.Var;
import semantic.types.LongInfo;

class CharInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new CharInfo ();
    }

    override bool isSame (InfoType other) {
	return cast (CharInfo) other !is null;
    }
    
    override InfoType BinaryOp (Word op, Expression right) {
	if (op == Tokens.EQUAL) return Affect (right);
	if (op == Tokens.MINUS_AFF) return opAff !(Tokens.MINUS) (right);
	if (op == Tokens.PLUS_AFF) return opAff!(Tokens.PLUS) (right);
	if (op == Tokens.INF) return opTest!(Tokens.INF) (right);
	if (op == Tokens.SUP) return opTest!(Tokens.SUP) (right);
	if (op == Tokens.DEQUAL) return opTest! (Tokens.DEQUAL) (right);
	if (op == Tokens.INF_EQUAL) return opTest!(Tokens.INF_EQUAL) (right);
	if (op == Tokens.SUP_EQUAL) return opTest!(Tokens.SUP_EQUAL) (right);
	if (op == Tokens.NOT_EQUAL) return opTest!(Tokens.NOT_EQUAL) (right);
	if (op == Tokens.NOT_INF) return opTest!(Tokens.SUP_EQUAL) (right);
	if (op == Tokens.NOT_SUP) return opTest!(Tokens.INF_EQUAL) (right);
	if (op == Tokens.NOT_INF_EQUAL) return opTest!(Tokens.SUP) (right);
	if (op == Tokens.NOT_SUP_EQUAL) return opTest!(Tokens.INF) (right);
	if (op == Tokens.PLUS) return opNorm!(Tokens.PLUS) (right);
	if (op == Tokens.MINUS) return opNorm!(Tokens.MINUS) (right);
	return null;
    }

    override InfoType BinaryOpRight (Word op, Expression right) {
	if (op == Tokens.EQUAL) return AffectRight (right);
	if (op == Tokens.INF) return opTestRight!(Tokens.INF) (right);
	if (op == Tokens.SUP) return opTestRight!(Tokens.SUP) (right);
	if (op == Tokens.INF_EQUAL) return opTestRight!(Tokens.INF_EQUAL) (right);
	if (op == Tokens.SUP_EQUAL) return opTestRight!(Tokens.SUP_EQUAL) (right);
	if (op == Tokens.NOT_EQUAL) return opTestRight!(Tokens.NOT_EQUAL) (right);
	if (op == Tokens.NOT_INF) return opTestRight!(Tokens.SUP_EQUAL) (right);
	if (op == Tokens.NOT_SUP) return opTestRight!(Tokens.INF_EQUAL) (right);
	if (op == Tokens.NOT_INF_EQUAL) return opTestRight!(Tokens.SUP) (right);
	if (op == Tokens.NOT_SUP_EQUAL) return opTestRight!(Tokens.INF) (right);
	if (op == Tokens.PLUS) return opNormRight!(Tokens.PLUS) (right);
	if (op == Tokens.MINUS) return opNormRight!(Tokens.MINUS) (right);
	return null;
    }

    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstAffect;
	    return ch;
	}
	return null;
    }
    
    private InfoType Affect (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstAffect;
	    return ch;
	}
	return null;
    }

    private InfoType opTest (Tokens op) (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new BoolInfo ();
	    ch.lintInst = &CharUtils.InstOpTest !(op);
	    return ch;
	} else if (cast (IntInfo) right.info.type) {
	    auto ch = new BoolInfo ();
	    ch.lintInst = &CharUtils.InstOpTestInt !(op);
	    return ch;
	} else if (cast (LongInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpTestInt! (op);
	    return ch;
	}
	return null;
    }
    
    private InfoType opTestRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto ch = new BoolInfo ();
	    ch.lintInst = &CharUtils.InstOpTestIntRight !(op);
	    return ch;
	} else if (cast (LongInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpTestIntRight ! (op);
	    return ch;
	}
	return null;
    }

    private InfoType opAff (Tokens op) (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpAff !(op);
	    return ch;
	} else if (cast (IntInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpAffInt!(op);
	    return ch;
	} else if (cast (LongInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpAffInt! (op);
	    return ch;
	}
	return null;
    }
    
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOp !(op);
	    return ch;
	} else if (cast (IntInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpInt!(op);
	    return ch;
	} else if (cast (LongInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpInt! (op);
	    return ch;
	}
	return null;
    }

    private InfoType opNormRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpIntRight!(op);
	    return ch;
	} else if (cast (LongInfo) right.info.type) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstOpIntRight! (op);
	    return ch;
	}
	return null;
    }

    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || cast (CharInfo) other) {
	    auto ch = new CharInfo ();
	    ch.lintInst = &CharUtils.InstAffect;
	    return ch;
	}
	return null;
    }
    
    
    override InfoType DotOp (Var var) {
	if (var.token.str == "init") return Init ();
	else if (var.token.str == "sizeof") return SizeOf ();
	else if (var.token.str == "typeid") return StringOf ();
	else return null;
    }

    private InfoType Init () {
	CharInfo _ch = new CharInfo ();
	_ch.lintInst = &CharUtils.CharInit;
	return _ch;
    }

    private InfoType SizeOf () {
	auto _int = new IntInfo ();
	_int.lintInst = &CharUtils.CharSizeOf;
	return _int;
    }

    private InfoType StringOf () {
	auto _str = new StringInfo ();
	if (this.isConst) 
	    _str.lintInst = &CharUtils.CharStringOfConst;
	else
	    _str.lintInst = &CharUtils.CharStringOf;
	return _str;
    }

    override string typeString () {
	return "char";
    }

    override InfoType clone () {
	return new CharInfo ();
    }

    override InfoType cloneForParam () {
	return new CharInfo ();
    }
    
    override InfoType CastOp (InfoType other) {
	if (cast(CharInfo) other) return this;
	return null;
    }
    
    override LSize size () {
	return LSize.BYTE;
    }

    static LSize sizeOf () {
	return LSize.INT;
    }
}
