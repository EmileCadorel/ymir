module semantic.types.UIntInfo;
import syntax.Word, ast.Expression, lint.LSize;
import semantic.types.InfoType, semantic.types.IntUtils;
import semantic.types.CharInfo, semantic.types.BoolInfo;
import syntax.Tokens, utils.exception, semantic.types.BoolInfo;
import ast.Var, semantic.types.PtrInfo, semantic.types.UndefInfo;
import semantic.types.RefInfo, semantic.types.StringInfo;
import semantic.types.FloatInfo;
import semantic.types.LongInfo, semantic.types.LongUtils;


/**
 Cette classe regroupe les informations de type du type int.
 */
class UIntInfo : InfoType {

    this () {
    }

    /**
     Params: 
     other = le deuxieme type.
     Returns: les deux type sont il identique ?
     */
    override bool isSame (InfoType other) {
	return (cast (UIntInfo) other) !is null;
    }

    /**
     Créé une instance de int.
     Params:
     token = l'identifiant du créateur.
     templates = les template de l'identifiant.
     Returns: une instance de int.
     Throws: NotATemplates.
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0) 
	    throw new NotATemplate (token);
	return new UIntInfo ();
    }

    /**
     La surcharge de operateur binaire de int.
     Params:
     token = l'operateur.
     right = l'operande droite.
     Returns: le type résultat ou null.
     */
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

    /**
     Surcharge des operateur binaire à droite.
     Params:
     op = l'operateur.
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOpRight (Word op, Expression left) {
	if (op == Tokens.EQUAL) return AffectRight (left);
	return null;
    }

    /**
     Surcharge des operateur unaire.
     Params:
     op = l'operateur.
     Returns: le type résultat ou null.
     */
    override InfoType UnaryOp (Word op) {
	if (op == Tokens.MINUS) {
	    auto ret = new UIntInfo ();
	    ret.lintInstS.insertBack (&IntUtils.InstUnop !(Tokens.MINUS));
	    return ret;
	} else if (op == Tokens.AND && !this.isConst) return toPtr ();
	else if (op == Tokens.DPLUS && !this.isConst) return pplus ();
	else if (op == Tokens.DMINUS && !this.isConst) return ssub ();
	return null;
    }

    /**
     Surcharge de l'operateur de cast.
     Params:
     other = le type vers lequel on veut caster.
     Returns: Le type résultat ou null.
     */
    override InfoType CastOp (InfoType other) {
	if (cast(UIntInfo)other !is null) return this;
	else if (cast(BoolInfo) other !is null) {
	    auto aux = new BoolInfo;
	    aux.lintInstS.insertBack (&IntUtils.InstCastBool);
	    return aux;
	} else if (cast (CharInfo) other !is null) {
	    auto aux = new CharInfo;
	    aux.lintInstS.insertBack (&IntUtils.InstCastChar);
	    return aux;
	} else if (cast (FloatInfo) other !is null) {
	    auto aux = new FloatInfo;
	    aux.lintInstS.insertBack (&IntUtils.InstCastFloat);
	    return aux;
	}
	return null;
    }

    /**
     Surcharge de l'operateur de cast automatique
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || cast (UIntInfo) other) {
	    auto ret = new UIntInfo ();
	    ret.lintInst = &IntUtils.InstAffect;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (cast (UIntInfo) _ref.content && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS.insertBack (&IntUtils.InstAddr);
		return aux;
	    }
	} else if (cast (LongInfo) other) {
	    auto o = new UIntInfo ();
	    o.lintInst = &LongUtils.InstAffect;
	    o.lintInstS.insertBack (&LongUtils.InstCastLong);
	    return o;
	}
	return null;
    }


    override InfoType CastTo (InfoType other) {
	if (cast (LongInfo) other) {
	    auto o = new LongInfo;
	    o.lintInstS.insertBack (&LongUtils.InstCastLong);
	    return o;
	}
	return null;
    }
    
    /**
     Operateur '&'
     Returns: un pointeur sur int.     
     */
    private InfoType toPtr () {
	auto other = new PtrInfo ();
	other.content = new UIntInfo ();
	other.lintInstS.insertBack (&IntUtils.InstAddr);
	return other;
    }

    /**
     Operateur '++'
     Returns: un int.
     */    
    private InfoType pplus () {
	auto other = new UIntInfo ();
	other.lintInstS.insertBack (&IntUtils.InstPplus);
	return other;
    }

    /**
     Operateur '--'.
     Returns: un int.
     */
    private InfoType ssub () {
	auto other = new UIntInfo ();
	other.lintInstS.insertBack (&IntUtils.InstSsub);
	return other;
    }

    /**
     Operateur '='.
     Params:
     right = l'operande droite
     Returns: le type résultat ou null.
     */
    private InfoType Affect (Expression right) {
	if (cast(UIntInfo)right.info.type !is null) {
	    auto i = new UIntInfo ();
	    i.lintInst = &IntUtils.InstAffect;
	    return i;
	}
	return null;
    }

    /**
     Operateur '=' à droite.
     Params:
     left = l'operande gauche.
     Returns: le type résultat ou null.
     */
    private InfoType AffectRight (Expression left) {
	if (cast(UndefInfo) left.info.type !is null) {
	    auto i = new UIntInfo ();
	    i.lintInst = &IntUtils.InstAffect;
	    return i;
	}
	return null;
    }
    
    /**
     Operateur d'affectation.
     Params:
     op = l'operateur.
     right = l'operande droite.
     Returns: le type résultat ou null.
     */
    private InfoType opAff (Tokens op) (Expression right) {
	if (cast(UIntInfo) right.info.type) {
	    auto i = new UIntInfo ();
	    i.lintInst = &IntUtils.InstOpAff!(op);
	    return i;
	}
	return null;
    }

    /**
     Operateur de test.
     Params:
     op = l'operateur.
     right = l'operande droite.
     Returns: le type résultat ou null.
     */
    private InfoType opTest (Tokens op) (Expression right) {
	if (cast(UIntInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &IntUtils.InstOpTest ! (op);
	    return b;
	}
	return null;
    }

    /**
     Tous les autres operateur.
     Params:
     op = l'operateur.
     right = l'operande droite.
     Returns: le type résultat ou null.
     */
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast (UIntInfo) right.info.type !is null) {
	    auto i = new UIntInfo ();
	    i.lintInst = &IntUtils.InstOp!(op);
	    return i;
	}
	return null;
    }

    /**
     Operateur '^^='
     Params:
     right = l'operande droite de l'expression
     Returns: le type résultat ou null.
     */
    private InfoType dxorAffOp (Expression right) {
	if (cast (UIntInfo) right.info.type) {
	    auto i = new UIntInfo ();
	    i.lintInst = &IntUtils.InstDXorAff;
	    return i;
	}
	return null;	
    }

    /**
     Operateur '^^'
     Params:
     right = l'operateur droite de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType dxorOp (Expression right) {
	if (cast (UIntInfo) right.info.type) {
	    auto i = new UIntInfo ();
	    i.lintInst = &IntUtils.InstDXor;
	    return i;
	}
	return null;
    }

    /**
     Operateur d'attribut.
     Params:
     var = l'attribut auquel on veut acceder
     Returns: Le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.token.str == "init") return Init ();
	else if (var.token.str == "max") return Max ();
	else if (var.token.str == "min") return Min ();
	else if (var.token.str == "sizeof") return SizeOf ();
	else if (var.token.str == "typeid") return StringOf ();
	return null;
    }

    
    /**
     La constante d'init de int
     Returns: un int.
     */
    private InfoType Init () {
	auto _int = new UIntInfo ();
	_int.lintInst = &IntUtils.IntInit;
	return _int;
    }

    /**
     La constante max de int
     Returns: un int.
     */
    private InfoType Max () {
	auto _int = new UIntInfo ();
	_int.lintInst = &IntUtils.IntMax;
	return _int;
    }
    
    /**
     La constante min de int
     Returns: un int.
     */
    private InfoType Min () {
	auto _int = new UIntInfo ();
	_int.lintInst = &IntUtils.IntMin;
	return _int;
    }

    /**
     La constante de taille de int
     Returns: un int.
     */
    private InfoType SizeOf () {
	auto _int = new UIntInfo ();
	_int.lintInst = &IntUtils.IntSizeOf ;
	return _int;
    }

    /**
     La constante de nom de int
     Returns: un string.
     */
    private InfoType StringOf () {
	auto _str = new StringInfo ();
	if (this.isConst) 
	    _str.lintInst = &IntUtils.IntStringOfConst;
	else
	    _str.lintInst = &IntUtils.IntStringOf;
	return _str;
    }

    /**
     Returns: le nom du type int.
     */
    override string typeString () {
	return "int";
    }

    /**
     Returns: le nom du type.
     */
    override string simpleTypeString () {
	return "i";
    }

    /**
     Returns: une nouvelle instance de int.
     */
    override InfoType clone () {
	return new UIntInfo ();
    }

    /**
     Returns: une nouvelle instance de int.
    */
    override InfoType cloneForParam () {
	return new UIntInfo ();
    }

    /**
     Returns: la taille en mémoire du type int.
     */
    override LSize size () {
	return LSize.UINT;
    }

    /**
     Returns: la taille en mémoire du type int.
     */
    static LSize sizeOf () {
	return LSize.UINT;
    }
    
}
