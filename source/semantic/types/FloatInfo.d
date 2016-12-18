module semantic.types.FloatInfo;
import syntax.Word, ast.Expression, semantic.types.FloatUtils;
import syntax.Tokens;
import semantic.types.InfoType, utils.exception;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo;

class FloatInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new FloatInfo ();
    }

    override bool isSame (InfoType other) {
	return (cast (FloatInfo) other) !is null;
    }
    
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	if (token == Tokens.DIV_AFF) return opAff! (Tokens.DIV) (right);
	if (token == Tokens.STAR_EQUAL) return opAff! (Tokens.STAR) (right);
	if (token == Tokens.MINUS_AFF) return opAff! (Tokens.MINUS) (right);
	if (token == Tokens.PLUS_AFF) return opAff! (Tokens.PLUS) (right);
	if (token == Tokens.INF) return opTest! (Tokens.INF) (right);	
	if (token == Tokens.SUP) return opTest! (Tokens.SUP) (right);
	if (token == Tokens.INF_EQUAL) return opTest! (Tokens.INF_EQUAL) (right);
	if (token == Tokens.SUP_EQUAL) return opTest! (Tokens.SUP_EQUAL) (right);
	if (token == Tokens.NOT_EQUAL) return opTest! (Tokens.NOT_EQUAL) (right);
	if (token == Tokens.NOT_INF) return opTest! (Tokens.SUP_EQUAL) (right);
	if (token == Tokens.NOT_INF_EQUAL) return opTest! (Tokens.SUP) (right);
	if (token == Tokens.NOT_SUP) return opTest! (Tokens.INF_EQUAL) (right);
	if (token == Tokens.NOT_SUP_EQUAL) return opTest! (Tokens.INF) (right);
	if (token == Tokens.DEQUAL) return opTest! (Tokens.DEQUAL) (right);
	if (token == Tokens.PLUS) return opNorm! (Tokens.PLUS) (right);
	if (token == Tokens.MINUS) return opNorm! (Tokens.MINUS) (right);
	if (token == Tokens.DIV) return opNorm! (Tokens.DIV) (right);
	if (token == Tokens.STAR) return opNorm! (Tokens.STAR) (right);
	return null;
    }

    override InfoType BinaryOpRight (Word token, Expression right) {
	if (token == Tokens.EQUAL) return AffectRight (right);
	if (token == Tokens.INF) return opTestRight! (Tokens.INF) (right);	
	if (token == Tokens.SUP) return opTestRight! (Tokens.SUP) (right);
	if (token == Tokens.INF_EQUAL) return opTestRight! (Tokens.INF_EQUAL) (right);
	if (token == Tokens.SUP_EQUAL) return opTestRight! (Tokens.SUP_EQUAL) (right);
	if (token == Tokens.NOT_EQUAL) return opTestRight! (Tokens.NOT_EQUAL) (right);
	if (token == Tokens.NOT_INF) return opTestRight! (Tokens.SUP_EQUAL) (right);
	if (token == Tokens.NOT_INF_EQUAL) return opTestRight! (Tokens.SUP) (right);
	if (token == Tokens.NOT_SUP) return opTestRight! (Tokens.INF_EQUAL) (right);
	if (token == Tokens.NOT_SUP_EQUAL) return opTestRight! (Tokens.INF) (right);
	if (token == Tokens.DEQUAL) return opTestRight! (Tokens.DEQUAL) (right);
	if (token == Tokens.PLUS) return opNormRight! (Tokens.PLUS) (right);
	if (token == Tokens.MINUS) return opNormRight! (Tokens.MINUS) (right);
	if (token == Tokens.DIV) return opNormRight! (Tokens.DIV) (right);
	if (token == Tokens.STAR) return opNormRight! (Tokens.STAR) (right);
	return null;
    }
    
    private InfoType Affect (Expression right) {
	if (cast(FloatInfo)right.info.type) {
	    auto f = new FloatInfo ();
	    f.lintInst = &FloatUtils.InstAffect;
	    return f;
	} else if (cast (IntInfo) right.info.type) {
	    auto f = new FloatInfo ();
	    f.lintInst = &FloatUtils.InstAffectInt;
	    return f;
	}
	return null;
    }

    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstAffect;
	    return fl;
	}
	return null;
    }
    
    override InfoType CastOp (InfoType other) {
	if (cast(FloatInfo)other !is null) return this;
	return null;
    }

    private InfoType opAff (Tokens op) (Expression right) {
	if (cast (FloatInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOpAff ! (op);
	    return fl;
	}
	return null;
    }    
    
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast (FloatInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOp ! (op);
	    return fl;
	} else if (cast (IntInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOpInt !(op);
	    return fl;
	}
	return null;
    }

    private InfoType opTest (Tokens op) (Expression right) {
	if (cast (FloatInfo) right.info.type) {
	    auto bl = new BoolInfo ();
	    bl.lintInst = &FloatUtils.InstOpTest ! (op);
	    return bl;
	} else if (cast (IntInfo) right.info.type) {
	    auto bl = new BoolInfo ();
	    bl.lintInst = &FloatUtils.InstOpTestInt !(op);
	    return bl;
	}
	return null;
    }
    
    private InfoType opNormRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOpIntRight !(op);
	    return fl;
	}
	return null;
    }

    private InfoType opTestRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto bl = new BoolInfo ();
	    bl.lintInst = &FloatUtils.InstOpTestIntRight !(op);
	    return bl;
	}
	return null;
    }
    

    override string typeString () {
	return "float";
    }

    override InfoType clone () {
	return new FloatInfo ();
    }

    override InfoType cloneForParam () {
	return new FloatInfo ();
    }

    override int size () {
	return -8;
    }
    
}
