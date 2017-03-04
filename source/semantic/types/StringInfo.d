module semantic.types.StringInfo;
import lint.LSize;
import syntax.Word, ast.Expression, syntax.Tokens;
import semantic.types.InfoType, utils.exception;
import semantic.types.StringUtils, ast.ParamList;
import semantic.types.CharInfo;
import ast.Var, semantic.types.UndefInfo, semantic.types.ArrayInfo;
import semantic.types.RefInfo, semantic.types.ClassUtils;
import std.container;
import semantic.types.ArrayUtils;
import semantic.types.NullInfo, semantic.types.BoolInfo;
import syntax.Keys, semantic.types.PtrInfo;
import semantic.types.DecimalInfo;
import ast.Constante;


/**
 Classe contenant les informatiosn de type d'une référence
 */
class StringInfo : InfoType {

    this () {
	this._destruct = &StringUtils.InstDestruct;
    }

    /**
     Operateur de cast automatique.
     Params:
     other = le type vers lequel on veut cast
     Returns: le type de retour ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (cast (StringInfo) other || cast (UndefInfo) other) {
	    auto ret = new StringInfo ();
	    ret.lintInstS.insertBack (&StringUtils.InstComp);
	    ret.lintInst = &ClassUtils.InstAffectRight;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (cast (StringInfo) _ref.content  && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS.insertBack (&StringUtils.InstAddr);
		return aux;
	    }
	}
	return null;
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
	return new StringInfo ();
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
	    auto str = new StringInfo ();
	    str.lintInst = &ClassUtils.InstAffect;
	    return str;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new StringInfo ();
	    ret.lintInst = &ClassUtils.InstAffectNull;
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
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstIs;
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
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstNotIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ClassUtils.InstNotIs;
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
	if (cast (StringInfo) right.info.type) {
	    auto str = new StringInfo ;
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
	if (cast (StringInfo) right.info.type) {
	    auto str = new StringInfo ();
	    str.lintInst = &StringUtils.InstPlus;
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
	    auto str = new StringInfo ();
	    str.lintInst = &ClassUtils.InstAffectRight;
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
	if (cast (StringInfo)info) return this;
	auto type = cast (ArrayInfo) info;
	if (type && cast (CharInfo) type.content) {
	    auto other = new ArrayInfo (new CharInfo);
	    other.setDestruct (null);
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
	vars [0].info.type = new RefInfo (new CharInfo ());
	vars [0].info.type.isConst = this.isConst;
	auto ret = new ArrayInfo (new CharInfo ());
	ret.leftTreatment = &ArrayUtils.InstApplyPreTreat;
	ret.lintInst = &ArrayUtils.InstApply;
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
	if (var.token.str == "nbRef") return NbRef ();
	if (var.token.str == "length") return Length ();
	else if (var.token.str == "dup") return Dup ();
	else if (var.token.str == "typeid") return StringOf ();
	else if (var.token.str == "ptr") return Ptr ();
	return null;
    }

    /**
     Traitement à appliquer quand on passe le string en paramètre.
     Returns: le type contenant le traitement.
     */
    override InfoType ParamOp () {
	auto str = new StringInfo ();
	str.lintInstS.insertBack (&ClassUtils.InstParam);
	return str;
    }

    /**
     Traitement à appliquer quand on retourne le string .
     Returns: le type contenant le traitement.
     */
    override InfoType ReturnOp () {
	auto str = new StringInfo ();
	str.lintInstS.insertBack (&ClassUtils.InstReturn);
	return str;
    }

    /**
     Le nombre de référence vers le string;
     Returns: un type int.
    */
    private InfoType NbRef () {
	auto _int = new DecimalInfo (DecimalConst.ULONG);
	_int.lintInst = &StringUtils.InstNbRef;
	return _int;
    }

    /**
     Le taille de la chaine.
     Returns: un type long.
     */
    private InfoType Length () {
	auto _int = new DecimalInfo (DecimalConst.ULONG);
	_int.lintInst = &StringUtils.InstLength ;
	return _int;
    }

    /**
     Une copie de la chaine.
     Returns: un type string.
     */
    private InfoType Dup () {
	auto str = new StringInfo ();
	str.lintInst = &StringUtils.InstDup;
	str.isConst = false;
	return str;
    }

    /**
     Le pointeur vers le contenu de la chaine.
     Returns: un type ptr!char
     */
    private InfoType Ptr () {
	auto ret = new PtrInfo (new CharInfo);
	ret.lintInst = &StringUtils.InstPtr;
	return ret;
    }

    /**
     Le nom du type.
     Returns: un type string.
     */
    private InfoType StringOf () {
	auto str = new StringInfo;
	str.lintInst = &StringUtils.StringOf;
	str.leftTreatment = &StringUtils.GetStringOf;
	return str;
    }

    /**
     Operateur d'acces pour un seul paramètre.
     Returns: un type char ou null.
     */
    private InfoType Access (Expression expr) {
	if (cast(DecimalInfo) expr.info.type) {
	    auto ch = new CharInfo;
	    ch.lintInstMult = &StringUtils.InstAccessS;
	    ch.isConst = false;
	    ch.setDestruct (null);
	    return ch;
	}
	return null;
    }

    /**
     Returns: le nom du type.
     */    
    override string typeString () {
	return "string";
    }
    
    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	return "s";
    }

    /**
     Retourne une copie du type (conserve les informations de destructions).
     Returns: un type string.
     */
    override InfoType clone () {
	auto ret = new StringInfo ();
	if (this._destruct is null) ret._destruct = null;
	return ret;
    }

    /**
     Retourne une copie du type (remet les informations de destruction à zero).
     Returns: un type string.
     */
    override InfoType cloneForParam () {
	return new StringInfo ();
    }

    /**
     Returns: la taille en mémoire du type.     
     */
    override LSize size () {
	return LSize.LONG;
    }

    /**
     Returns: Le type contenant les informations de destruction.
     */
    override InfoType destruct () {
	if (this._destruct is null) return null;
	auto ret = new StringInfo ();
	ret.setDestruct (this._destruct);
	return ret;
    }

}

