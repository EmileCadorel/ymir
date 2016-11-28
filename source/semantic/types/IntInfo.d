module semantic.types.IntInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType, semantic.types.IntUtils;
import syntax.Tokens, utils.exception, semantic.types.BoolInfo;

class IntInfo : InfoType {

    this () {
    }
    
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0) 
	    throw new NotATemplate (token);
	return new IntInfo ();
    }

    override InfoType BinaryOp (Word token, Expression right) {
	switch (token.str) {
	case Tokens.EQUAL.descr: return Affect (right);
	case Tokens.DIV_AFF.descr: return opAff !(Tokens.DIV) (right);
	case Tokens.AND_AFF.descr: return opAff !(Tokens.AND) (right);
	case Tokens.PIPE_EQUAL.descr: return opAff!(Tokens.PIPE) (right);
	case Tokens.MINUS_AFF.descr: return opAffInv!(Tokens.MINUS) (right);
	case Tokens.PLUS_AFF.descr: return opAff!(Tokens.PLUS) (right);
	case Tokens.LEFTD_AFF.descr: return opAff!(Tokens.LEFTD) (right);
	case Tokens.RIGHTD_AFF.descr: return opAff!(Tokens.RIGHTD) (right);
	case Tokens.STAR_EQUAL.descr: return opAff!(Tokens.STAR) (right);
	case Tokens.PERCENT_EQUAL.descr: return opAff!(Tokens.PERCENT) (right);
	case Tokens.XOR_EQUAL.descr: return opAff!(Tokens.XOR) (right);
	case Tokens.DXOR_EQUAL.descr: return dxorAffOp (right);
	case Tokens.DAND.descr: return opNorm!(Tokens.DAND) (right);
	case Tokens.DPIPE.descr: return opNorm!(Tokens.DPIPE) (right);
	case Tokens.INF.descr: return opTest!(Tokens.INF) (right);
	case Tokens.SUP.descr: return opTest!(Tokens.SUP) (right);
	case Tokens.INF_EQUAL.descr: return opTest!(Tokens.INF_EQUAL) (right);
	case Tokens.SUP_EQUAL.descr: return opTest!(Tokens.SUP_EQUAL) (right);
	case Tokens.NOT_EQUAL.descr: return opTest!(Tokens.NOT_EQUAL) (right);
	case Tokens.NOT_INF.descr: return opTest!(Tokens.SUP_EQUAL) (right);
	case Tokens.NOT_INF_EQUAL.descr: return opTest!(Tokens.SUP) (right);
	case Tokens.NOT_SUP.descr: return opTest!(Tokens.INF_EQUAL) (right);
	case Tokens.NOT_SUP_EQUAL.descr: return opTest!(Tokens.INF) (right);
	case Tokens.DEQUAL.descr: return opTest!(Tokens.DEQUAL) (right);
	case Tokens.PLUS.descr: return opNorm !(Tokens.PLUS) (right);
	case Tokens.MINUS.descr: return opNormInv !(Tokens.MINUS) (right);
	case Tokens.DIV.descr: return opNorm !(Tokens.DIV) (right);
	case Tokens.STAR.descr: return opNorm !(Tokens.STAR) (right);
	case Tokens.PIPE.descr: return opNorm!(Tokens.PIPE) (right);
	case Tokens.LEFTD.descr: return opNorm!(Tokens.LEFTD) (right);
	case Tokens.XOR.descr: return opNorm!(Tokens.XOR) (right);
	case Tokens.RIGHTD.descr: return opNorm!(Tokens.RIGHTD) (right);
	case Tokens.PERCENT.descr: return opNorm!(Tokens.PERCENT) (right);
	case Tokens.DXOR.descr: return dxorOp (right);
	default: return null;
	}
    }

    override InfoType CastOp (InfoType other) {
	if (cast(IntInfo)other !is null) return this;
	return null;
    }
    
    private InfoType Affect (Expression right) {
	if (cast(IntInfo)right.info.type !is null) {
	    auto i = new IntInfo ();
	    i.lintInst = &IntUtils.InstAffect;
	    return i;
	}
	return null;
    }

    private InfoType opAff (Tokens op) (Expression right) {
	if (cast(IntInfo) right.info.type) {
	    auto i = new IntInfo ();
	    i.lintInst = &IntUtils.InstOpAff!(op);
	    return i;
	}
	return null;
    }

    private InfoType opAffInv (Tokens op) (Expression right) {
	if (cast(IntInfo) right.info.type) {
	    auto i = new IntInfo ();
	    i.lintInst = &IntUtils.InstOpAffInv!(op);
	    return i;
	}
	return null;
    }

    
    private InfoType opTest (Tokens op) (Expression right) {
	if (cast(IntInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &IntUtils.InstOpTest ! (op);
	    return b;
	}
	return null;
    }
    
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type !is null) {
	    auto i = new IntInfo ();
	    i.lintInst = &IntUtils.InstOp!(op);
	    return i;
	}
	return null;
    }

    private InfoType opNormInv (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type !is null) {
	    auto i = new IntInfo ();
	    i.lintInst = &IntUtils.InstOpInv!(op);
	    return i;
	}
	return null;
    }

    private InfoType dxorAffOp (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto i = new IntInfo ();
	    i.lintInst = &IntUtils.InstDXorAff;
	    return i;
	}
	return null;	
    }
    
    private InfoType dxorOp (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto i = new IntInfo ();
	    i.lintInst = &IntUtils.InstDXor;
	    return i;
	}
	return null;
    }

    
    override string typeString () {
	return "int";
    }

    override InfoType clone () {
	return new IntInfo ();
    }    

    override int size () {
	return 8;
    }
    
}
