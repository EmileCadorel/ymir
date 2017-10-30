module ymir.semantic.types.StringInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;


/**
 Classe contenant les informatiosn de type d'une référence
 */
class StringInfo : InfoType {

    this (bool isConst) {
	super (isConst);
    }

    /**
     Operateur de cast automatique.
     Params:
     other = le type vers lequel on veut cast
     Returns: le type de retour ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (cast (StringInfo) other || cast (UndefInfo) other) {
	    auto ret = new StringInfo (this.isConst);
	    ret.lintInstS.insertBack (&StringUtils.InstComp);
	    ret.lintInst = &ClassUtils.InstAffectRight;
	    ret.isConst = this.isConst;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (cast (StringInfo) _ref.content  && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS.insertBack (&StringUtils.InstAddr);
		return aux;
	    }
	} else if (auto en = cast (EnumInfo) other) {
	    return this.CompOp (en.content);
	} 
	return null;
    }

    /**
       this -> other
       Returns: On peut passer de l'un à l'autre sans casser la verification constante ?  
    */
    override InfoType ConstVerif (InfoType other) {
	if (this.isConst && !other.isConst) return null;
	else if (!this.isConst && other.isConst) {
	    this.isConst = false;
	}
	return this;
    }
    
    
    /**
     Returns : other est de type string ?
     */
    override bool isSame (InfoType other) {
	return (cast (StringInfo) other) !is null;
    }

    /**
     Créé une instance de type string en fonction de paramètre template
     Params:
     token = l'identificateur du createur
     templates = les paramètres templates du type
     Returns: une instance de string
     Throws: NotATemplate
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new StringInfo (false);
    } 
   
    /**
     Surcharge des operateurs binaire
     Params:
     token = l'operateur
     right = l'operande droite de l'expression
     Returns: le type résultat ou null
     */
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	else if (token == Tokens.PLUS) return Plus (right);
	else if (token == Tokens.PLUS_AFF) return PlusAff (right);
	else if (token == Keys.IS) return Is (right);
	else if (token == Keys.NOT_IS) return NotIs (right);
	else if (token == Tokens.DEQUAL) return Equal (right);
	else if (token == Tokens.NOT_EQUAL) return NotEqual (right);
	else return null;
    }

    /**
     Surcharge des operateurs binaires à droite
     Params:
     token = l'operateur
     left = l'operande gauche de l'expression
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	else return null;
    }

    /**
     Operateur d'affectation
     Params:
     right = l'operande droite de l'expression
     Returns: le type de retour ou null.
     */
    private InfoType Affect (Expression right) {
	if (cast(StringInfo)right.info.type) {
	    auto str = new StringInfo (false);
	    str.lintInst = &StringUtils.InstAffect;
	    return str;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new StringInfo (false);
	    ret.lintInst = &ArrayUtils.InstAffectNull;
	    return ret;	    
	}
	return null;
    }    

    /**
     Operateur 'is'.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type de retour ou null.
     */
    private InfoType Is (Expression right) {
	if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ArrayUtils.InstIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ArrayUtils.InstIs;
	    return ret;
	}
	return null;
    }
    
    /**
     Operateur '!is'
     Params:
     right = l'operande droite de l'expression
     Returns: le type de retour ou null.
     */
    private InfoType NotIs (Expression right) {
	if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ClassUtils.InstNotIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ClassUtils.InstNotIs;
	    return ret;
	}
	return null;
    }    


    /**
     Operateur '=='
     Params:
     right = l'operande droite de l'expression
     Returns: le type de retour ou null
     */
    private InfoType Equal (Expression right) {
	if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &StringUtils.InstEqual;
	    if (this._value)
		ret.value = this._value.BinaryOp (Tokens.DEQUAL, right.info.type.value);
	    return ret;
	}
	return null;
    }

    private InfoType NotEqual (Expression right) {
	if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &StringUtils.InstNotEqual;
	    if (this._value)
		ret.value = this._value.BinaryOp (Tokens.NOT_EQUAL, right.info.type.value);
	    return ret;
	}
	return null;
    }
    
    /**
     Operateur '+='
     Params:
     right = l'operande droite de l'expression.
     Returns: le type de retour ou null.
     */
    private InfoType PlusAff (Expression right) {
	if (auto t = cast (StringInfo) right.info.type) {
	    auto str = new StringInfo (false);
	    str.lintInst = &StringUtils.InstPlusAffect;
	    return str;
	}
	return null;
    }

    /**
     Operateur '+'.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type de retour ou null.
     */
    private InfoType Plus (Expression right) {
	if (auto t = cast (StringInfo) right.info.type) {
	    auto str = new StringInfo (true);
	    str.lintInst = &StringUtils.InstPlus;
	    str.isConst = true;
	    if (this._value)
		str.value = this._value.BinaryOp (Tokens.PLUS, t._value);
	    return str;
	} else if (auto t = cast (CharInfo) right.info.type) {
	    auto str = new StringInfo (true);
	    str.lintInst = &StringUtils.InstPlusChar;
	    str.isConst = true;
	    if (this._value)
		str.value = this._value.BinaryOp (Tokens.PLUS, t.value);
	    return str;
	}
	return null;
    }

    /**
     Operateur '=' à droite.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type de retour ou null.
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto str = new StringInfo (true);
	    str.lintInst = &StringUtils.InstAffect;
	    return str;
	}
	return null;
    }
    
    /**
     Operateur de cast.
     Params:
     info = le type vers lequel on veut caster
     Returns: le type de retour ou null.
     */
    override InfoType CastOp (InfoType info) {
	if (cast (StringInfo) info) return this;
	auto type = cast (ArrayInfo) info;
	if (type && cast (CharInfo) type.content) {
	    auto other = new ArrayInfo (this.isConst, new CharInfo (this.isConst));
	    other.lintInstS.insertBack (&StringUtils.InstCastArray);
	    return other;
	}
	return null; 
    }

    /**
     Operateur de boucle 'for'.
     Params:
     vars = les paramètres de la boucle for.
     Returns: le type de retour ou null.
     */
    override InfoType ApplyOp (Array!Var vars) {
	if (vars.length != 1) return null;
	if (this.isConst) {
	    vars [0].info.type = new CharInfo (this.isConst);
	    vars [0].info.type.isConst = this.isConst;
	} else {
	    vars [0].info.type = new RefInfo (new CharInfo (false));
	    vars [0].info.type.isConst = this.isConst;
	}
	auto ret = new ArrayInfo (this.isConst, new CharInfo (this.isConst));
	ret.leftTreatment = &ArrayUtils.InstApplyPreTreat;
	ret.lintInst = &ArrayUtils.InstApply;
	ret.isConst = this.isConst;
	return ret;
    }

    /**
     Operateur d'acces '[]'.
     Params:
     params = les paramètres d'accés.
     Returns: le type de retour ou null.
     */
    override InfoType AccessOp (Word, ParamList params) {
	if (params.params.length == 1) {
	    return Access (params.params [0]);
	} else {
	    return null;
	}
    }

    /**
     Operateur d'attribut '.'.
     Params;
     var = l'attribut demandé.
     Returns: le type de retour ou null.
     */
    override InfoType DotOp (Var var) {
	InfoType ret = null;
	if (var.templates.length != 0) return null;
	if (var.token.str == "length") ret = Length ();
	else if (var.token.str == "typeid") return StringOf ();
	else if (var.token.str == "ptr") ret = Ptr ();
	if (ret && this._value) ret.value = this._value.DotOp (var);
	return ret;
    }

    /**
     Traitement à appliquer quand on passe le string en paramètre.
     Returns: le type contenant le traitement.
     */
    override InfoType ParamOp () {
	auto str = new StringInfo (this.isConst);
	str.lintInstS.insertBack (&ClassUtils.InstParam);
	return str;
    }

    /**
     Traitement à appliquer quand on retourne le string .
     Returns: le type contenant le traitement.
     */
    override InfoType ReturnOp () {
	auto str = new StringInfo (this.isConst);
	str.lintInstS.insertBack (&ClassUtils.InstReturn);
	return str;
    }

    /**
     Le taille de la chaine.
     Returns: un type long.
     */
    private InfoType Length () {
	auto _int = new DecimalInfo (true, DecimalConst.ULONG);
	_int.lintInst = &ArrayUtils.InstLength ;
	return _int;
    }

    /**
     Le pointeur vers le contenu de la chaine.
     Returns: un type ptr!char
     */
    private InfoType Ptr () {
	auto ret = new PtrInfo (this.isConst, new CharInfo (this.isConst));
	ret.lintInst = &ArrayUtils.InstPtr;
	return ret;
    }

    /**
     Le nom du type.
     Returns: un type string.
     */
    private InfoType StringOf () {
	auto str = new StringInfo (true);
	str.value = new StringValue (this.typeString);
	return str;
    }

    /**
     Operateur d'acces pour un seul paramètre.
     Returns: un type char ou null.
     */
    private InfoType Access (Expression expr) {
	if (cast(DecimalInfo) expr.info.type) {
	    auto ch = new CharInfo (this.isConst);
	    ch.lintInstMult = &ArrayUtils.InstAccessS!(LSize.UBYTE);
	    if (this._value)
		ch.value = this._value.AccessOp (expr);
	    return ch;
	}
	return null;
    }

    /**
     Returns: le nom du type.
     */    
    override string innerTypeString () {
	return "string";
    }
    
    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	if (this.isConst) return "cs";
	return "s";
    }

    /**
     Retourne une copie du type (conserve les informations de destructions).
     Returns: un type string.
     */
    override InfoType clone () {
	auto ret = new StringInfo (this.isConst);
	ret.value = this._value;
	return ret;
    }

    override Expression toYmir () {
	Word w = Word.eof;
	w.str = "string";
	auto ret = new Var (w);
	ret.info = new Symbol (w, this.clone ());
	return ret;
    }

    /**
     Retourne une copie du type (remet les informations de destruction à zero).
     Returns: un type string.
     */
    override InfoType cloneForParam () {
	return new StringInfo (this.isConst);
    }

    /**
     Returns: la taille en mémoire du type.     
     */
    override LSize size () {
	return LSize.LONG;
    }

}

