module semantic.types.LongInfo;
import syntax.Word, ast.Expression;
import semantic.types.InfoType, semantic.types.LongUtils;
import semantic.types.CharInfo, semantic.types.BoolInfo;
import syntax.Tokens, utils.exception, semantic.types.PtrInfo;
import semantic.types.UndefInfo, semantic.types.RefInfo;
import semantic.types.StringInfo, ast.Var, semantic.types.IntInfo;
import lint.LSize;

class LongInfo : InfoType {

    
    this () {
    }

    override bool isSame (InfoType other) {
	return (cast (LongInfo) other) !is null;
    }
    
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0) 
	    throw new NotATemplate (token);
	return new LongInfo ();
    }

    override InfoType BinaryOp (Word token, Expression right) {
	switch (token.str) {
	case Tokens.EQUAL.descr: return Affect (right);
	case Tokens.DIV_AFF.descr: return opAff !(Tokens.DIV) (right);
	case Tokens.AND_AFF.descr: return opAff !(Tokens.AND) (right);
	case Tokens.PIPE_EQUAL.descr: return opAff!(Tokens.PIPE) (right);
	case Tokens.MINUS_AFF.descr: return opAff!(Tokens.MINUS) (right);
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
	case Tokens.MINUS.descr: return opNorm !(Tokens.MINUS) (right);
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

    override InfoType BinaryOpRight (Word op, Expression right) {
	if (op == Tokens.EQUAL) return AffectRight (right);
	switch (op.str) {
	case Tokens.DAND.descr: return opNormRight!(Tokens.DAND) (right);
	case Tokens.DPIPE.descr: return opNormRight!(Tokens.DPIPE) (right);
	case Tokens.INF.descr: return opTestRight!(Tokens.INF) (right);
	case Tokens.SUP.descr: return opTestRight!(Tokens.SUP) (right);
	case Tokens.INF_EQUAL.descr: return opTestRight!(Tokens.INF_EQUAL) (right);
	case Tokens.SUP_EQUAL.descr: return opTestRight!(Tokens.SUP_EQUAL) (right);
	case Tokens.NOT_EQUAL.descr: return opTestRight!(Tokens.NOT_EQUAL) (right);
	case Tokens.NOT_INF.descr: return opTestRight!(Tokens.SUP_EQUAL) (right);
	case Tokens.NOT_INF_EQUAL.descr: return opTestRight!(Tokens.SUP) (right);
	case Tokens.NOT_SUP.descr: return opTestRight!(Tokens.INF_EQUAL) (right);
	case Tokens.NOT_SUP_EQUAL.descr: return opTestRight!(Tokens.INF) (right);
	case Tokens.DEQUAL.descr: return opTestRight!(Tokens.DEQUAL) (right);
	case Tokens.PLUS.descr: return opNormRight !(Tokens.PLUS) (right);
	case Tokens.MINUS.descr: return opNormRight !(Tokens.MINUS) (right);
	case Tokens.DIV.descr: return opNormRight !(Tokens.DIV) (right);
	case Tokens.STAR.descr: return opNormRight !(Tokens.STAR) (right);
	case Tokens.PIPE.descr: return opNormRight!(Tokens.PIPE) (right);
	case Tokens.LEFTD.descr: return opNormRight!(Tokens.LEFTD) (right);
	case Tokens.XOR.descr: return opNormRight!(Tokens.XOR) (right);
	case Tokens.RIGHTD.descr: return opNormRight!(Tokens.RIGHTD) (right);
	case Tokens.PERCENT.descr: return opNormRight!(Tokens.PERCENT) (right);
	case Tokens.DXOR.descr: return dxorOpRight (right);
	default : return null;
	}
    }

    override InfoType UnaryOp (Word op) {
	if (op == Tokens.MINUS) {
	    auto ret = new LongInfo;
	    ret.lintInstS.insertBack (&LongUtils.InstUnop !(Tokens.MINUS));
	    return ret;
	} else if (op == Tokens.AND && !this.isConst) return toPtr ();
	else if (op == Tokens.DPLUS && !this.isConst) return pplus ();
	else if (op == Tokens.DMINUS && !this.isConst) return ssub ();
	else return null;
    }

    override InfoType CastOp (InfoType other) {
	if (cast(LongInfo)other !is null) return this;
	else if (cast(BoolInfo) other !is null) {
	    auto aux = new BoolInfo;
	    aux.lintInstS.insertBack (&LongUtils.InstCastBool);
	    return aux;
	} else if (cast (CharInfo) other !is null) {
	    auto aux = new CharInfo;
	    aux.lintInstS.insertBack (&LongUtils.InstCastChar);
	    return aux;
	} else if (cast (IntInfo) other !is null) {
	    auto aux = new IntInfo ();
	    aux.lintInstS.insertBack (&LongUtils.InstCastInt);
	    return aux;
	}
	return null;
    }

    override InfoType CompOp (InfoType other) {	
	if (cast (UndefInfo) other || cast (LongInfo) other)  {
	    auto o = new LongInfo ();
	    o.lintInst = &LongUtils.InstAffect;
	    return o;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (cast (LongInfo) _ref.content && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS.insertBack (&LongUtils.InstAddr);
		return aux;
	    }
	}
	return null;
    }

    private InfoType toPtr () {
	auto other = new PtrInfo ();
	other.content = new LongInfo ();
	other.lintInstS.insertBack (&LongUtils.InstAddr);
	return other;
    }

    private InfoType pplus () {
	auto other = new LongInfo ();
	other.lintInstS.insertBack (&LongUtils.InstPplus);
	return other;
    }

    private InfoType ssub () {
	auto other = new LongInfo ();
	other.lintInstS.insertBack (&LongUtils.InstSsub);
	return other;
    }

    private InfoType Affect (Expression right) {
	if (cast (LongInfo) right.info.type !is null) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstAffect;
	    return l;
	} else if (cast (IntInfo) right.info.type !is null) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstAffectInt;
	    return l;
	}
	return null;
    }

    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type !is null) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstAffect;
	    return l;
	}
	return null;
    }

    private InfoType opAff (Tokens op) (Expression right) {
	if (cast (LongInfo) right.info.type) {
	    auto i = new LongInfo ();
	    i.lintInst = &LongUtils.InstOpAff !(op);
	    return i;
	} else if (cast (IntInfo) right.info.type) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstOpAffInt! (op);
	    return l;
	}
	return null;
    }

    private InfoType opTest (Tokens op) (Expression right) {
	if (cast (LongInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &LongUtils.InstOpTest!(op);
	    return b; 
	} else if (cast (IntInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &LongUtils.InstOpTestInt !(op);
	    return b;
	}
	return null;
    }

    private InfoType opTestRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &LongUtils.InstOpTestIntRight !(op);
	    return b;
	}
	return null;
    }
    
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast (LongInfo) right.info.type !is null) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstOp !(op);
	    return l;
	} else if (cast (IntInfo) right.info.type !is null) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstOpInt! (op);
	    return l;
	}
	return null;
    }
        
    private InfoType opNormRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type !is null) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstOpIntRight ! (op);
	    return l;
	}
	return null;
    }

    private InfoType opNormInv (Tokens op) (Expression right) {
	if (cast (LongInfo) right.info.type !is null) {
	    auto l = new LongInfo ();
	    l.lintInst = &LongUtils.InstOp !(op);
	    return l;
	} else if (cast (IntInfo) right.info.type !is null) {
	    auto l = new IntInfo ();
	    l.lintInst = &LongUtils.InstOpInt !(op);
	    return l;
	}
	return null;      
    }

    private InfoType opNormInvRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type !is null) {
	    auto l = new IntInfo ();
	    l.lintInst = &LongUtils.InstOpIntRight !(op);
	    return l;
	}
	return null;      
    }
    
    private InfoType dxorAffOp (Expression right) {
	if (cast (LongInfo) right.info.type) {
	    auto l = new LongInfo;
	    l.lintInst = &LongUtils.InstDXorAff;
	    return l;
	} else if (cast (IntInfo) right.info.type) {
	    auto l = new LongInfo;
	    l.lintInst = &LongUtils.InstDXorAffInt;
	    return l;
	}
	return null;	
    }

    private InfoType dxorOp (Expression right) {
	if (cast (LongInfo) right.info.type) {
	    auto l = new LongInfo;
	    l.lintInst = &LongUtils.InstDXor;
	    return l;
	} else if (cast (IntInfo) right.info.type) {
	    auto l = new IntInfo;
	    l.lintInst = &LongUtils.InstDXorInt;
	    return l;
	}
	return null;
    }

    private InfoType dxorOpRight (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto l = new IntInfo;
	    l.lintInst = &LongUtils.InstDXorIntRight;
	    return l;
	}
	return null;
    }

    
    override InfoType DotOp (Var var) {
	if (var.token.str == "init") return Init ();
	else if (var.token.str == "max") return Max ();
	else if (var.token.str == "min") return Min ();
	else if (var.token.str == "sizeof") return SizeOf ();
	else if (var.token.str == "typeid") return StringOf ();
	return null;
    }

    private InfoType Init () {
	auto _int = new LongInfo ();
	_int.lintInst = &LongUtils.IntInit;
	return _int;
    }

    private InfoType Max () {
	auto _int = new LongInfo ();
	_int.lintInst = &LongUtils.IntMax;
	return _int;
    }

    private InfoType Min () {
	auto _int = new LongInfo ();
	_int.lintInst = &LongUtils.IntMin;
	return _int;
    }

    private InfoType SizeOf () {
	auto _int = new IntInfo ();
	_int.lintInst = &LongUtils.IntSizeOf ;
	return _int;
    }

    private InfoType StringOf () {
	auto str = new StringInfo ();
	str.lintInst = &LongUtils.StringOf;
	str.leftTreatment = &LongUtils.GetStringOf;
	return str;
    }
    
    override string typeString () {
	return "long";
    }

    override InfoType clone () {
	return new LongInfo ();
    }

    override InfoType cloneForParam () {
	return new LongInfo ();
    }

    override LSize size () {
	return LSize.LONG;
    }

    static LSize sizeOf () {
	return LSize.LONG;
    }
    
    

}
