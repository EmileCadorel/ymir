module semantic.types.ArrayInfo;

import utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import syntax.Tokens;
import semantic.types.ArrayUtils, syntax.Keys;
import semantic.types._;
import ast.ParamList;
import lint.LSize, semantic.types.ClassUtils;
import std.container;
import ast.Constante;


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
	auto arr = other.match!(ArrayInfo);
	if (arr is null) return false;
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
	    if (auto _cst = templates [0].info.type.match!(StructCstInfo)) {
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
	vars [0].info.type = new RefInfo (this._content.clone ());
	vars [0].info.type.isConst = false;
	auto ret = this.clone ();
	ret.leftTreatment = &ArrayUtils.InstApplyPreTreat;
	ret.lintInst = &ArrayUtils.InstApply;
	return ret;
    }
    
    /**
     Operateur 'is'.
     Params:
     right = l'operande droite de l'operation.
     Returns: le type résultat ou null.
    */
    private InfoType Is (Expression right) {
	if (auto _ptr = right.info.type.match!(NullInfo)) {
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
     Operateur '!is'.
     Params:
     right = l'operande droite de l'operation.
     Returns: le type résultat ou null.
    */
    private InfoType NotIs (Expression right) {
	if (auto _ptr = right.info.type.match!(NullInfo)) {
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
	if (left.info.type.match!(UndefInfo)) {
	    auto arr = new ArrayInfo (this._content.clone ());
	    arr.lintInst = &ClassUtils.InstAffectRight;
	    return arr;
	}
	return null;
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
	import semantic.types.PtrInfo;
	auto ret = new PtrInfo (this._content.clone ());
	ret.lintInst = &ArrayUtils.InstPtr;
	return ret;
    }
    
    /**
     Returns: Le type résultat de 'array.length'
     */
    protected InfoType Length () {
	if (this._content.match!(VoidInfo)) return null; 
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
	import semantic.types.TupleInfo;
	import semantic.types.PtrInfo;
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
	if (auto ot = expr.info.type.match!(DecimalInfo)) {
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
	    ch.lintInstSR = ot.lintInstSR;
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
	auto type = left.info.type.match!(ArrayInfo);
	if (type  && type._content.isSame (this._content)) {
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ClassUtils.InstAffect;
	    return ret;
	} else if (type && this._content.match!(VoidInfo)) {
	    this._content = type._content.clone ();
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ClassUtils.InstAffect;
	    return ret;
	} else if (left.info.type.match!(NullInfo)) {
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
	auto type = other.match!(ArrayInfo);
	if (type && type.content.isSame (this._content)) {
	    return this;
	} else if (other.match!(StringInfo) && this._content.match!(CharInfo)) {
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
	if ((type && type.content.isSame (this._content)) || other.match!(UndefInfo)) {
	    auto ret = new ArrayInfo (this._content.clone ());
	    ret.lintInst = &ClassUtils.InstAffectRight;
	    return ret;
	} else if (type && this._content.match!(VoidInfo)) {
	    auto ret = other.clone ();
	    ret.lintInst = &ClassUtils.InstAffectRight;
	    return ret;
	} else if (auto _ref = other.match!(RefInfo)) {
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
	return "[" ~ this._content.typeString () ~ "]";
    }

    /**
     Returns: le type du tableau sou forme de chaine simplifié.
     */    
    override string simpleTypeString () {
	return "A" ~ this._content.simpleTypeString ();
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
