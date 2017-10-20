module ymir.semantic.types.CharInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

/**
 La classe qui regroupent les informations de type du type char.
 */
class CharInfo : InfoType {


    this (bool isConst) {
	super (isConst);
    }
    
    /**
     Création du type char, à partir d'un variable de création.
     Pour fonctionner, templates doit être vide
     Params:
     token = l'emplacement du créateur
     templates = les élément templates du créateur.
     Returns: une instance de type char.
     Throws: NotATemplate
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new CharInfo (false);
    }
    
    /**
     Params:
     other = le deuxieme type.
     Returns: Les deux types sont il identique ?
     */
    override bool isSame (InfoType other) {
	return cast (CharInfo) other !is null;
    }

    /**
     La surcharge des opérateur binaire du type char.
     Params:
     op = l'operateur.
     right = l'operande droite dans l'expression.
     Returns: le type résultat ou null.
     */
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

    /**
     La surcharge des opérateur binaire droit du type char.
     Params:
     op = l'operateur binaire
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.     
     */
    override InfoType BinaryOpRight (Word op, Expression left) {
	if (op == Tokens.EQUAL) return AffectRight (left);
	if (op == Tokens.INF) return opTestRight!(Tokens.INF) (left);
	if (op == Tokens.SUP) return opTestRight!(Tokens.SUP) (left);
	if (op == Tokens.INF_EQUAL) return opTestRight!(Tokens.INF_EQUAL) (left);
	if (op == Tokens.SUP_EQUAL) return opTestRight!(Tokens.SUP_EQUAL) (left);
	if (op == Tokens.NOT_EQUAL) return opTestRight!(Tokens.NOT_EQUAL) (left);
	if (op == Tokens.NOT_INF) return opTestRight!(Tokens.SUP_EQUAL) (left);
	if (op == Tokens.NOT_SUP) return opTestRight!(Tokens.INF_EQUAL) (left);
	if (op == Tokens.NOT_INF_EQUAL) return opTestRight!(Tokens.SUP) (left);
	if (op == Tokens.NOT_SUP_EQUAL) return opTestRight!(Tokens.INF) (left);
	if (op == Tokens.PLUS) return opNormRight!(Tokens.PLUS) (left);
	if (op == Tokens.MINUS) return opNormRight!(Tokens.MINUS) (left);
	return null;
    }

    /**
     Opérateur '='.
     Params:
     left = l'operande gauche de l'expression.
     Returns: Le type résultat ou null.
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ch = new CharInfo (false);
	    ch.lintInst = &CharUtils.InstAffect;
	    return ch;
	}
	return null;
    }

    /**
     Opérateur '='.
     Params:
     right = l'operande droite de l'expression.
     Returns: Le type résultat ou null.
     */
    private InfoType Affect (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new CharInfo (false);
	    ch.lintInst = &CharUtils.InstAffect;
	    return ch;
	}
	return null;
    }

    /**
     La surchage des opérateurs de test.
     Params:
     op = l'operateur
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType opTest (Tokens op) (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new BoolInfo (true);
	    ch.lintInst = &CharUtils.InstOpTest !(op);
	    if (this._value)
		ch.value = this._value.BinaryOp (op, right.info.type.value);
	    return ch;
	} else if (auto ot = cast (DecimalInfo) right.info.type) {
	    if (ot.type == DecimalConst.UBYTE) {
		auto ch = new BoolInfo (true);
		if (this._value)
		    ch.value = this._value.BinaryOp (op, right.info.type.value);
		ch.lintInst = &CharUtils.InstOpTest !(op);
		return ch;
	    }
	} 
	return null;
    }

    /**
     La surchage des opérateurs de test à droite.
     Params:
     op = l'operateur
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType opTestRight (Tokens op) (Expression left) {
	if (auto ot = cast (DecimalInfo) left.info.type) {
	    if (ot.type == DecimalConst.UBYTE) {
		auto ch = new BoolInfo (true);
		if (this._value)
		    ch.value = this._value.BinaryOpRight (op, left.info.type.value);
		ch.lintInst = &CharUtils.InstOpTest !(op);
		return ch;
	    }
	}
	return null;
    }

    /**
     La surcharge des opérateur d'affectation de char (example: pour '+=' => op = '+')
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: Le type résultat ou null.
     */
    private InfoType opAff (Tokens op) (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new CharInfo (false);
	    ch.lintInst = &CharUtils.InstOpAff !(op);	    
	    return ch;
	} else if (auto ot = cast (DecimalInfo) right.info.type) {
	    if (ot.type == DecimalConst.UBYTE) {
		auto ch = new CharInfo (false);
		ch.lintInst = &CharUtils.InstOpAff !(op);
		return ch;
	    }
	}
	return null;
    }

    /**
     La surcharge de tous les autres opérateur.
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: Le type résultat de l'expression.
     */
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast (CharInfo) right.info.type) {
	    auto ch = new CharInfo (true);
	    ch.lintInst = &CharUtils.InstOp !(op);
	    if (this._value)
		ch.value = this._value.BinaryOp (op, right.info.type.value);
	    return ch;
	} else if (auto ot = cast (DecimalInfo) right.info.type) {
	    if (ot.type == DecimalConst.UBYTE) {
		auto ch = new CharInfo (true);
		if (this._value)
		    ch.value = this._value.BinaryOp (op, right.info.type.value);
		ch.lintInst = &CharUtils.InstOp ! (op);
		return ch;
	    }
	}
	return null;
    }

    /**
     La surcharge de tous les autres opérateur droits.
     Params:
     op = l'operateur.
     left = l'operande gauche de l'expression.
     Returns: Le type résultat de l'expression.
     */
    private InfoType opNormRight (Tokens op) (Expression left) {
	if (auto ot = cast (DecimalInfo) left.info.type) {
	    if (ot.type == DecimalConst.UBYTE) {
		auto ch = new CharInfo (true);
		if (this._value)
		    ch.value = this._value.BinaryOpRight (op, left.info.type.value);
		ch.lintInst = &CharUtils.InstOp ! (op);
		return ch;
	    }
	} 
	return null;
    }

    /**
     Surcharge de l'operateur de cast automatique.
     Params:
     other = le type vers lequel on essai de caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || cast (CharInfo) other) {
	    auto ch = new CharInfo (this.isConst);
	    ch.lintInst = &CharUtils.InstAffect;
	    return ch;
	}
	return null;
    }
    
    /**
     Opérateur '.'.
     Params:
     var = l'attribut auquel on veut accéder.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.templates.length != 0) return null;
	if (var.token.str == "init") return Init ();
	else if (var.token.str == "sizeof") return SizeOf ();
	else if (var.token.str == "typeid") return StringOf ();
	else return null;
    }

    /**
     La constante d'initialisation de char (char.init);
     Returns: un type char.
     */
    private InfoType Init () {
	CharInfo _ch = new CharInfo (true);
	_ch.lintInst = &CharUtils.CharInit;
	return _ch;
    }

    /**
     La constante de taille du type char (char.sizeof).
     Returns: un type int (TODO changer en ubyte).
     */
    private InfoType SizeOf () {
	auto _int = new DecimalInfo (true, DecimalConst.UBYTE);
	_int.lintInst = &CharUtils.CharSizeOf;
	return _int;
    }

    /**
     La constante de nom du type char. (char.typeid).
     Returns: un type string.
     */
    private InfoType StringOf () {
	auto _str = new StringInfo (true);
	_str.value = new StringValue (this.typeString);
	return _str;
    }

    /**
     Returns: le nom du type char.
     */
    override string innerTypeString () {
	return "char";
    }

    /**
     Returns: le nom du type char simplifié
     */
    override string simpleTypeString () {
	return "a";
    }
    
    /**
     Returns: un nouvelle instance du type char.
     */
    override InfoType clone () {
	auto ret = new CharInfo (this.isConst);
	ret.value = this._value;
	return ret;
    }

    /**
     Returns: une nouvelle instance du type char.
     */
    override InfoType cloneForParam () {
	return new CharInfo (this.isConst);
    }

    /**
     Surchage de l'operateur de cast.
     Params:
     other = le type vers lequel on veut caster.
     Returns: Le type résultat ou null.
     */
    override InfoType CastOp (InfoType other) {
	if (cast(CharInfo) other) return this;
	else if (auto ot = cast (DecimalInfo) other) {
	    auto aux = ot.clone ();
	    final switch (ot.type.id) {
	    case DecimalConst.BYTE.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.BYTE)); break;
	    case DecimalConst.UBYTE.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.UBYTE)); break;
	    case DecimalConst.SHORT.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.SHORT)); break;
	    case DecimalConst.USHORT.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.USHORT)); break;
	    case DecimalConst.INT.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.INT)); break;
	    case DecimalConst.UINT.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.UINT)); break;
	    case DecimalConst.LONG.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.LONG)); break;
	    case DecimalConst.ULONG.id : aux.lintInstS.insertBack (&CharUtils.InstCast ! (DecimalConst.ULONG)); break;
	    }
	    return aux;
	}
	return null;
    }

    /**
     Returns: la taille en mémoire du type char.
     */
    override LSize size () {
	return LSize.BYTE;
    }

    /**
     Returns: la taille en mémoire du type char.
     */
    static LSize sizeOf () {
	return LSize.BYTE;
    }
}
