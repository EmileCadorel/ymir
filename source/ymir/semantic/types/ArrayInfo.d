module ymir.semantic.types.ArrayInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container, std.format;

/**
 Déclaration d'une information de tableau.
 */
class ArrayInfo : InfoType {

    /** Le type contenu dans le tableau */
    protected InfoType _content = null;

    /**
     Initialise le tableau en [void].
     */
    this () {
	this._content = new VoidInfo ();
    }

    /**
     Params:
     content = le type contenu dans le tableau
     */
    this (InfoType content) {
	this._content = content;
    }

    /**
     Returns: Le type contenu dans le tableau
     */
    InfoType content () {
	return this._content;
    }

    /**
     Les deux types sont ils identiques ?
     Params:
     other = le deuxieme type
     */
    override bool isSame (InfoType other) {
	auto arr = cast (ArrayInfo) other;
	if (arr is null) return false;
	if (this.isConst != other.isConst) return false;
	if (this._content is arr._content) return true;       
	return arr._content.isSame (this._content);
    }

    /**
     Créé une information de tableau en fonction d'une déclaration template.
     Pour être correct, templates doit contenir un Type.
     Params:
     token = l'identifiant du déclarateur de tableau
     templates = les informations templates du déclarateur.
     Returns: Un type tableau
     Throws: UndefinedType
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast (Type) templates [0])) {
	    if (auto _cst = cast (StructCstInfo) templates [0].info.type) {
		return new ArrayInfo (_cst.create (templates [0].token, []));
	    } else
		throw new UndefinedType (token, "prend un type en template");
	} else {
	    auto arr = new ArrayInfo (templates [0].info.type);
	    return arr;
	}
    }
    
    /**
     Test des surcharge d'operateur du tableau.
     Params:
     token = l'operateur
     right = l'operande droite de l'expression
     Returns: Le type résultat de l'operation ou null.
     */
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	else if (token == Keys.IS) return Is (right);
	else if (token == Keys.NOT_IS) return NotIs (right);
	return null;
    }

    /**
     Test de surcharge d'operateur du tableau.
     Params:
     token = l'operateur
     left = l'operande gauche de l'expression
     Returns: le type résultat de l'operation ou null.
     */
    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	return null;
    }

    /**
     Test de surcharge de l'operateur d'itération.
     Params:
     vars = les itérateurs.
     Returns: l'information résultat de l'operation, ou null.
     */
    override InfoType ApplyOp (Array!Var vars) {	
	if (vars.length != 1) return null;
	if (this.isConst) {
	    vars [0].info.type = this._content.clone ();
	} else {
	    vars [0].info.type = new RefInfo (this._content.clone ());
	    vars [0].info.type.isConst = false;
	}
	auto ret = this.clone ();
	ret.leftTreatment = &ArrayUtils.InstApplyPreTreat;
	ret.lintInst = &ArrayUtils.InstApply;
	ret.isConst = this.isConst;
	return ret;
    }
    
    /**
     Operateur 'is'.
     Params:
     right = l'operande droite de l'operation.
     Returns: le type résultat ou null.
    */
    private InfoType Is (Expression right) {
	if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ArrayUtils.InstIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &ArrayUtils.InstIs;
	    return ret;
	}
	return null;
    }

    /**
     Operateur '!is'.
     Params:
     right = l'operande droite de l'operation.
     Returns: le type résultat ou null.
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
     Operateur '='.
     Params:
     left = l'operande gauche de l'operation.
     Returns: le type résultat ou null.
    */
    protected InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto arr = new ArrayInfo (this._content.clone ());
	    arr.lintInst = &ClassUtils.InstAffectRight;
	    return arr;
	}
	return null;
    }

    /**
     l'operation à efféctué lorsqu'on passe le tableau en paramètre (se fait dans la frame appelé).
     Returns: le type résultat ou null.
    */
    override InfoType ParamOp () {
	auto str = new ArrayInfo (this._content.clone);
	str.lintInstS.insertBack (&ClassUtils.InstParam);
	return str;
    }

    /**
     l'operation à efféctué lorsqu'on retourne le tableau.
     Returns: le type résultat ou null.
    */
    override InfoType ReturnOp () {
	auto str = new ArrayInfo (this._content.clone);
	str.lintInstS.insertBack (&ClassUtils.InstReturn);
	return str;
    }

    /**
     L'operateur '[]'.
     Params:
     params = la liste des paramètre dans l'operateur.
     Returns: Le type résultat ou null.
     */
    override InfoType AccessOp (Word, ParamList params) {
	if (params.params.length == 1) {
	    return Access (params.params [0]);
	}
	return null;
    }

    /**
     L'operateur '.'.
     Params:
     var = l'attribut auquel on veut accéder.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.templates.length != 0) return null;
	else if (var.token.str == "length") return Length;
	else if (var.token.str == "typeid") return StringOf;
	else if (var.token.str == "ptr") return toPtr;
	else if (var.token.str == "tupleof") return TupleOf;
	return null;
    }
    
    /**
     Le pointeur vers le contenu de la chaine.
     Returns: un type ptr!char
     */
    private InfoType toPtr () {
	auto ret = new PtrInfo (this._content.clone ());
	ret.lintInst = &ArrayUtils.InstPtr;
	return ret;
    }
    
    /**
     Returns: Le type résultat de 'array.length'
     */
    protected InfoType Length () {
	if (cast (VoidInfo) this._content) return null; 
	auto elem = new DecimalInfo (DecimalConst.ULONG);
	elem.lintInst = &ArrayUtils.InstLength;
	return elem;
    }

    /**
     Returns: Le type résultat de 'array.typeid'
     */
    private InfoType StringOf () {
	auto _str = new StringInfo;
	_str.value = new StringValue (this.typeString);
	return _str;
    }

    /++
     [].tupleof;
     +/
    private InfoType TupleOf () {
	auto t = new TupleInfo ();
	t.params = make!(Array!InfoType) ([new DecimalInfo (DecimalConst.ULONG),
					  new PtrInfo (new VoidInfo)]);
	t.lintInst = &ArrayUtils.InstCastTuple;
	return t;
    }
    
    /**
     L'operateur '[]' avec un seul paramètre.
     Params:
     expr = le paramètre des '[]'.
     Returns: Le type résultat ou null.
     */
    private InfoType Access (Expression expr) {
	if (auto ot = cast (DecimalInfo) expr.info.type) {
	    auto ch = this._content.clone ();
	    switch (ch.size.id) {
	    case LSize.BYTE.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.BYTE); break;
	    case LSize.UBYTE.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.BYTE); break;
	    case LSize.SHORT.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.SHORT); break;
	    case LSize.USHORT.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.SHORT); break;
	    case LSize.INT.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.INT); break;
	    case LSize.UINT.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.INT); break;
	    case LSize.LONG.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.LONG); break;
	    case LSize.ULONG.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.LONG); break;
	    case LSize.FLOAT.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.FLOAT); break;
	    case LSize.DOUBLE.id: ch.lintInstMult = &ArrayUtils.InstAccessS! (LSize.DOUBLE); break;
	    default : return null;
	    }
	    ch.isConst = false;
	    return ch;
	}
	return null;
    }

    /**
     Operateur '='.
     Params:
     left = l'operande droite ^^ de l'expression.
     Returns: Le type résultat ou null.
     */
    private InfoType Affect (Expression left) {
	auto type = cast (ArrayInfo) left.info.type;
	if (type  && type._content.isSame (this._content)) {
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ClassUtils.InstAffect;
	    return ret;
	} else if (type && cast (VoidInfo) this._content) {
	    this._content = type._content.clone ();
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ClassUtils.InstAffect;
	    return ret;
	} else if (cast (NullInfo) left.info.type) {
	    auto ret = this.clone ();
	    ret.lintInst = &ClassUtils.InstAffectNull;
	    return ret;	    
	}
	return null;
    }

    /**
     Returns: Clone du type. Les informations de déstruction sont conservées.
     */
    override InfoType clone () {
	auto ret = new ArrayInfo (this._content.clone ());
	ret.value = this._value;
	ret.isConst = this.isConst;
	return ret;
    }

    /**
     Returns: Clone du type. Les informations de déstruction sont remisent à zéro.
     */
    override InfoType cloneForParam () {
	return new ArrayInfo (this._content.clone ());
    }

    /**
     Operateur de 'cast' .
     Params:
     other = le type vers lequel on tente le cast.
     Returns: Le type résultat ou null.
     */
    override InfoType CastOp (InfoType other) {
	auto type = cast (ArrayInfo) other;
	if (type && type.content.isSame (this._content)) {
	    return this;
	} else if (cast(StringInfo) other && cast(CharInfo) this._content) {
	    auto _other = new StringInfo ();
	    _other.lintInstS.insertBack (&ArrayUtils.InstCastString);
	    return _other;
	}
	return null;	
    }

    /**
     Operateur de comparaison (cast automatique).
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	auto type = cast (ArrayInfo) other;
	if ((type && type.content.isSame (this._content))) {
	    if (this.isConst && !other.isConst) return null;
	    else if (!this.isConst && other.isConst) {
		auto ret = new ArrayInfo (this._content.clone ());
		ret.lintInst = &ClassUtils.InstAffectRight;
		ret.isConst = true;
		return ret;
	    } else {
		auto ret = new ArrayInfo (this._content.clone ());
		ret.lintInst = &ClassUtils.InstAffectRight;
		return ret;
	    }
	} else if (cast (UndefInfo) other) {
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ClassUtils.InstAffectRight;
	    return ret;
	} else if (type && cast (VoidInfo) this._content) {
	    auto ret = other.clone ();
	    ret.lintInst = &ClassUtils.InstAffectRight;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (auto arr = cast (ArrayInfo) _ref.content) {
		if (arr.content.isSame (this._content) && !this.isConst) {
		    auto aux = new RefInfo (this.clone ());
		    aux.lintInstS.insertBack (&ArrayUtils.InstAddr);
		    return aux;
		}
	    }
	} else if (cast (NullInfo) other) {
	    return this.clone ();
	}
	return null;
    }

    /**
     Returns: Le type du tableau sous forme de chaine.
     */
    override string typeString () {
	if (this.isConst) return format ("const ([%s])", this._content.typeString);
	else return format ("[%s]", this._content.typeString);
    }

    /**
     Returns: le type du tableau sou forme de chaine simplifié.
     */    
    override string simpleTypeString () {
	if (this.isConst) return format ("cA%s", this._content.simpleTypeString);
	else return format ("A%s", this._content.simpleTypeString);
    }
    
    /**
     Returns: la place que prend une instance de tableau (sont pointeur).
     */
    override LSize size () {
	return LSize.LONG;
    }

    override InfoType getTemplate (ulong i) {
	if (i == 0) return this._content;
	return null;
    }
}
