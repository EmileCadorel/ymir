module semantic.types.DecimalInfo;
import syntax.Word, ast.Expression, lint.LSize;
import semantic.types.InfoType;
import semantic.types.CharInfo, semantic.types.BoolInfo;
import syntax.Tokens, utils.exception, semantic.types.BoolInfo;
import ast.Var, semantic.types.PtrInfo, semantic.types.UndefInfo;
import semantic.types.RefInfo, semantic.types.StringInfo;
import semantic.types.FloatInfo;
import semantic.types.DecimalUtils;
import ast.Constante;

/**
 Cette classe regroupe les informations de type du type int.
 */
class DecimalInfo : InfoType {

    private DecimalConst _type;
    
    this (DecimalConst type) {
	this._type = type;
    }

    /**
     Params: 
     other = le deuxieme type.
     Returns: les deux type sont il identique ?
     */
    override bool isSame (InfoType other) {
	auto ot = cast (DecimalInfo) other;
	if (ot && ot.type == this._type) {
	    return true;
	} return false;
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
	
	switch (token.str) {
	case "byte" : return new DecimalInfo (DecimalConst.BYTE);
	case "ubyte" : return new DecimalInfo (DecimalConst.UBYTE);
	case "short" : return new DecimalInfo (DecimalConst.SHORT);
	case "ushort" : return new DecimalInfo (DecimalConst.USHORT);
	case "int" : return new DecimalInfo (DecimalConst.INT);
	case "uint" : return new DecimalInfo (DecimalConst.UINT);
	case "long" : return new DecimalInfo (DecimalConst.LONG);
	case "ulong" : return new DecimalInfo (DecimalConst.ULONG);
	default : assert (false);
	}
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
	InfoType ret;
	if (op == Tokens.MINUS) {
	    ret = new DecimalInfo (this._type);
	    ret.lintInstS.insertBack (&DecimalUtils.InstUnop !(Tokens.MINUS));
	    if (this._value)
		ret.value = this._value.UnaryOp (op);
	    return ret;
	} else if (op == Tokens.AND && !this.isConst) return toPtr ();
	if (this._value && ret)
	    ret.value = this._value.UnaryOp (op);
	return ret;
    }

    /**
     Surcharge de l'operateur de cast.
     Params:
     other = le type vers lequel on veut caster.
     Returns: Le type résultat ou null.
     */
    override InfoType CastOp (InfoType other) {
	if (this.isSame (other)) return this;
	else if (cast(BoolInfo) other !is null) {
	    auto aux = new BoolInfo;
	    aux.lintInstS.insertBack (&DecimalUtils.InstCastBool);
	    return aux;
	} else if (cast (CharInfo) other !is null) {
	    auto aux = new CharInfo;
	    aux.lintInstS.insertBack (&DecimalUtils.InstCastChar);
	    return aux;
	} else if (cast (FloatInfo) other !is null) {
	    auto aux = new FloatInfo;
	    aux.lintInstS.insertBack (&DecimalUtils.InstCastFloat);
	    return aux;
	} else if (auto ot = cast (DecimalInfo) other) {
	    auto ret = new DecimalInfo (ot.type);
	    final switch (ot.type.id) {
	    case DecimalConst.BYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
	    case DecimalConst.UBYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
	    case DecimalConst.SHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
	    case DecimalConst.USHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
	    case DecimalConst.INT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
	    case DecimalConst.UINT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
	    case DecimalConst.LONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
	    case DecimalConst.ULONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;	    
	    }
	    return ret;
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
	if (cast (UndefInfo) other || this.isSame (other)) {
	    auto ret = new DecimalInfo (this._type);
	    ret.lintInst = &DecimalUtils.InstAffect;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (cast (DecimalInfo) _ref.content && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS.insertBack (&DecimalUtils.InstAddr);
		return aux;
	    }
	} else if (auto ot = cast (DecimalInfo) other) {
	    if (this._type.isSigned && ot.type.isSigned && this._type.id < ot.type.id) {
		auto ret = this.clone ();
		final switch (ot.type.id) {
		case DecimalConst.BYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
		case DecimalConst.SHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
		case DecimalConst.INT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
		case DecimalConst.LONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
		}
		ret.lintInst = &DecimalUtils.InstAffect;
		return ret;				    
	    } else if (!this._type.isSigned && !ot.type.isSigned && this._type.id < ot.type.id) {
		auto ret = this.clone ();
		final switch (ot.type.id) {
		case DecimalConst.UBYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
		case DecimalConst.USHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
		case DecimalConst.UINT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
		case DecimalConst.ULONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;
		}
		ret.lintInst = &DecimalUtils.InstAffect;
		return ret;				    
	    }
	}
	return null;
    }


    override InfoType CastTo (InfoType other) {
	if (auto ot = cast (DecimalInfo) other) {
	    auto ret = new DecimalInfo (ot.type);
	    final switch (ot.type.id) {
	    case DecimalConst.BYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
	    case DecimalConst.UBYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
	    case DecimalConst.SHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
	    case DecimalConst.USHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
	    case DecimalConst.INT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
	    case DecimalConst.UINT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
	    case DecimalConst.LONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
	    case DecimalConst.ULONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;	    
	    }
	    return ret;
	}	
	return null;
    }
    
    /**
     Operateur '&'
     Returns: un pointeur sur int.     
    */
    private InfoType toPtr () {
	auto other = new PtrInfo ();
	other.content = new DecimalInfo (this._type);
	other.lintInstS.insertBack (&DecimalUtils.InstAddr);
	return other;
    }
    
    /**
     Operateur '++'
     Returns: un int.
    */    
    private InfoType pplus () {
	auto other = new DecimalInfo (this._type);
	other.lintInstS.insertBack (&DecimalUtils.InstPplus);
	return other;
    }

    /**
     Operateur '--'.
     Returns: un int.
     */
    private InfoType ssub () {
	auto other = new DecimalInfo (this._type);
	other.lintInstS.insertBack (&DecimalUtils.InstSsub);
	return other;
    }

    /**
     Operateur '='.
     Params:
     right = l'operande droite
     Returns: le type résultat ou null.
     */
    private InfoType Affect (Expression right) {
	if (auto ot = cast (DecimalInfo) right.info.type) {
	    if (this._type.isSigned && ot.type.isSigned && this._type.id > ot.type.id) {
		auto ret = this.clone ();
		final switch (this._type.id) {
		case DecimalConst.BYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
		case DecimalConst.SHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
		case DecimalConst.INT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
		case DecimalConst.LONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
		}
		ret.lintInst = &DecimalUtils.InstAffect;
		return ret;				    
	    } else if (!this._type.isSigned && !ot.type.isSigned && this._type.id > ot.type.id) {
		auto ret = this.clone ();
		final switch (this._type.id) {
		case DecimalConst.UBYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
		case DecimalConst.USHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
		case DecimalConst.UINT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
		case DecimalConst.ULONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;
		}
		ret.lintInst = &DecimalUtils.InstAffect;
		return ret;				    
	    } else if (this._type == ot.type) {
		auto ret = this.clone ();
		ret.lintInst = &DecimalUtils.InstAffect;
		return ret;
	    }
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
	    auto i = new DecimalInfo (this._type);
	    i.lintInst = &DecimalUtils.InstAffect;
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
	if (auto ot = cast (DecimalInfo) right.info.type) {
	    if (this._type.isSigned && ot.type.isSigned && this._type.id > ot.type.id) {
		auto ret = this.clone ();
		final switch (this._type.id) {
		case DecimalConst.BYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
		case DecimalConst.SHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
		case DecimalConst.INT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
		case DecimalConst.LONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
		}
		ret.lintInst = &DecimalUtils.InstOpAff! (op);
		return ret;				    
	    } else if (!this._type.isSigned && !ot.type.isSigned && this._type.id > ot.type.id) {
		auto ret = this.clone ();
		final switch (this._type.id) {
		case DecimalConst.UBYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
		case DecimalConst.USHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
		case DecimalConst.UINT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
		case DecimalConst.ULONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;
		}
		ret.lintInst = &DecimalUtils.InstOpAff !(op);
		return ret;				    
	    } else if (this._type == ot.type) {
		auto ret = this.clone ();
		ret.lintInst = &DecimalUtils.InstOpAff! (op);
		return ret;
	    }
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
	if (auto ot = cast (DecimalInfo) right.info.type) {
	    if (this._type == ot.type) {
		auto ret = new BoolInfo ();
		if (this._value)
		    ret.value = this.value.BinaryOp (op, right.info.type.value);
		ret.lintInst = &DecimalUtils.InstOpTest! (op);
		return ret;
	    } else if (this._type.isSigned && ot.type.isSigned) {
		if (this._type.id > ot.type.id) {
		    auto ret = new BoolInfo ();
		    final switch (this._type.id) {
		    case DecimalConst.BYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
		    case DecimalConst.SHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
		    case DecimalConst.INT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
		    case DecimalConst.LONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOpTest! (op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    return ret;
		} else {
		    auto ret = new BoolInfo ();
		    final switch (ot._type.id) {
		    case DecimalConst.BYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
		    case DecimalConst.SHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
		    case DecimalConst.INT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
		    case DecimalConst.LONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOpTest! (op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    return ret;
		}
	    } else if (!this._type.isSigned && !ot.type.isSigned) {
		if (this._type.id > ot.type.id) {
		    auto ret = new BoolInfo ();
		    final switch (this._type.id) {
		    case DecimalConst.UBYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
		    case DecimalConst.USHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
		    case DecimalConst.UINT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
		    case DecimalConst.ULONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOpTest !(op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    return ret;
		} else {
		    auto ret = new BoolInfo ();
		    final switch (ot._type.id) {
		    case DecimalConst.UBYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
		    case DecimalConst.USHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
		    case DecimalConst.UINT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
		    case DecimalConst.ULONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOpTest !(op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    return ret;
		}
	    }
	} else if (auto ot = cast (CharInfo) right.info.type) {
	    if (this._type == DecimalConst.UBYTE) {
		auto ret = new BoolInfo ();
		if (this._value)
		    ret.value = this.value.BinaryOp (op, ot.value);
		ret.lintInst = &DecimalUtils.InstOpTest ! (op);
		return ret;
	    }
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
	if (this.isSame (right.info.type)) {
	    auto ret = this.clone ();
	    if (this._value)
		ret.value = this.value.BinaryOp (op, right.info.type.value);
	    ret.lintInst = &DecimalUtils.InstOp! (op);
	    return ret;
	} else if (auto ot = cast (DecimalInfo) right.info.type) {
	    if (this._type.isSigned && ot.type.isSigned) {
		if (this._type.id > ot.type.id) {
		    auto ret = this.clone ();
		    final switch (this._type.id) {
		    case DecimalConst.BYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
		    case DecimalConst.SHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
		    case DecimalConst.INT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
		    case DecimalConst.LONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOp ! (op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    return ret;
		} else {
		    auto ret = ot.clone ();
		    final switch (ot.type.id) {
		    case DecimalConst.BYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.BYTE)); break;
		    case DecimalConst.SHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.SHORT)); break;
		    case DecimalConst.INT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.INT)); break;
		    case DecimalConst.LONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.LONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOp ! (op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    else ret.value = null;
		    return ret;
		}		
	    } else if (!this._type.isSigned && !ot.type.isSigned) {
		if (this._type.id > ot.type.id) {
		    auto ret = this.clone ();
		    final switch (this._type.id) {
		    case DecimalConst.UBYTE.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
		    case DecimalConst.USHORT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
		    case DecimalConst.UINT.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
		    case DecimalConst.ULONG.id : ret.lintInstSR.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOp !(op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    return ret;				    
		} else {
		    auto ret = ot.clone ();
		    final switch (ot.type.id) {
		    case DecimalConst.UBYTE.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UBYTE)); break;
		    case DecimalConst.USHORT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.USHORT)); break;
		    case DecimalConst.UINT.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.UINT)); break;
		    case DecimalConst.ULONG.id : ret.lintInstS.insertBack (&DecimalUtils.InstCast! (DecimalConst.ULONG)); break;
		    }
		    ret.lintInst = &DecimalUtils.InstOp !(op);
		    if (this._value)
			ret.value = this.value.BinaryOp (op, ot.value);
		    else ret.value = null;
		    return ret;		
		}
	    }
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
	if (cast (DecimalInfo) right.info.type) {
	    auto i = new DecimalInfo (this._type);
	    i.value = this._value.BinaryOp (Tokens.DXOR, right.info.type.value);
	    i.lintInst = &DecimalUtils.InstDXorAff;
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
	if (cast (DecimalInfo) right.info.type) {
	    auto i = new DecimalInfo (this._type);
	    i.value = this._value.BinaryOp (Tokens.DXOR, right.info.type.value);
	    i.lintInst = &DecimalUtils.InstDXor;
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
	auto _int = new DecimalInfo (this._type);
	final switch (this._type.id) {
	case DecimalConst.BYTE.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.BYTE); break;
	case DecimalConst.UBYTE.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.UBYTE); break;
	case DecimalConst.SHORT.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.SHORT); break;
	case DecimalConst.USHORT.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.USHORT); break;
	case DecimalConst.INT.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.INT); break;
	case DecimalConst.UINT.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.UINT); break;
	case DecimalConst.LONG.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.LONG); break;
	case DecimalConst.ULONG.id :  _int.lintInst = &DecimalUtils.Init!(DecimalConst.ULONG); break;
	}
	return _int;
    }

    /**
     La constante max de int
     Returns: un int.
     */
    private InfoType Max () {
	auto _int = new DecimalInfo (this._type);
	final switch (this._type.id) {
	case DecimalConst.BYTE.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.BYTE); break;
	case DecimalConst.UBYTE.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.UBYTE); break;
	case DecimalConst.SHORT.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.SHORT); break;
	case DecimalConst.USHORT.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.USHORT); break;
	case DecimalConst.INT.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.INT); break;
	case DecimalConst.UINT.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.UINT); break;
	case DecimalConst.LONG.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.LONG); break;
	case DecimalConst.ULONG.id :  _int.lintInst = &DecimalUtils.Max!(DecimalConst.ULONG); break;
	}
	return _int;
    }
    
    /**
     La constante min de int
     Returns: un int.
     */
    private InfoType Min () {
	auto _int = new DecimalInfo (this._type);
	final switch (this._type.id) {
	case DecimalConst.BYTE.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.BYTE); break;
	case DecimalConst.UBYTE.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.UBYTE); break;
	case DecimalConst.SHORT.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.SHORT); break;
	case DecimalConst.USHORT.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.USHORT); break;
	case DecimalConst.INT.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.INT); break;
	case DecimalConst.UINT.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.UINT); break;
	case DecimalConst.LONG.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.LONG); break;
	case DecimalConst.ULONG.id :  _int.lintInst = &DecimalUtils.Min!(DecimalConst.ULONG); break;
	}
	return _int;
    }

    /**
     La constante de taille de int
     Returns: un int.
     */
    private InfoType SizeOf () {
	auto _int = new DecimalInfo (DecimalConst.UBYTE);
	final switch (this._type.id) {
	case DecimalConst.BYTE.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.BYTE); break;
	case DecimalConst.UBYTE.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.UBYTE); break;
	case DecimalConst.SHORT.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.SHORT); break;
	case DecimalConst.USHORT.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.USHORT); break;
	case DecimalConst.INT.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.INT); break;
	case DecimalConst.UINT.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.UINT); break;
	case DecimalConst.LONG.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.LONG); break;
	case DecimalConst.ULONG.id :  _int.lintInst = &DecimalUtils.SizeOf!(DecimalConst.ULONG); break;
	}
	return _int;
    }

    /**
     La constante de nom de int
     Returns: un string.
     */
    private InfoType StringOf () {
	auto _str = new StringInfo ();
	_str.lintInst = &DecimalUtils.StringOf;
	_str.leftTreatment = &DecimalUtils.GetStringOf;
	_str.value = new StringValue (this.typeString);
	return _str;
    }

    /**
     Returns: le nom du type int.
     */
    override string typeString () {
	return this._type.name;
    }

    /**
     Returns: le nom du type.
     */
    override string simpleTypeString () {
	return this._type.sname;
    }

    /**
     Returns: une nouvelle instance de int.
     */
    override InfoType clone () {
	auto ret = new DecimalInfo (this._type);
	ret.value = this._value;
	return ret;
    }

    /**
     Returns: une nouvelle instance de int.
    */
    override InfoType cloneForParam () {
	return new DecimalInfo (this._type);
    }

    /**
     Returns: la taille en mémoire du type int.
     */
    override LSize size () {
	return fromDecimalConst (this._type);
    }

    DecimalConst type () {
	return this._type;
    }
    
}
