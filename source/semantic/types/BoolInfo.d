module semantic.types.BoolInfo;
import syntax.Word, ast.Expression;
import semantic.types.CharInfo;
import semantic.types.InfoType, utils.exception;
import semantic.types.UndefInfo;
import syntax.Tokens, semantic.types.BoolUtils;
import semantic.types.PtrInfo;
import lint.LSize, ast.Var, semantic.types.StringInfo;
import semantic.types.DecimalInfo, ast.Constante;


/**
 Classe contenant les informations du type bool.
 */
class BoolInfo : InfoType {

    /**
     Créé une instance du type bool.
     Pour fonctionner templates doit être vide.
     Params:
     token = l'emplacement du créateur
     templates = les templates utilisé pour créée bool.
     Returns: Une instance de type bool.
     Throws: NotATemplate.
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new BoolInfo ();
    }
    
    /**
     Params:
     other = le deuxième type.
     Returns: Les deux types sont identique ?
     */
    override bool isSame (InfoType other) {
	return cast (BoolInfo) other !is null;
    }

    /**
     Operateur binaire pour le type bool.
     Params:
     op = l'operateur
     right = l'operande droite de l'expression
     Returns: Le type résultat ou null.
     */
    override InfoType BinaryOp (Word op, Expression right) {
	if (op == Tokens.EQUAL) return Affect (right);
	if (op == Tokens.DAND) return opNorm !(Tokens.DAND) (right);
	if (op == Tokens.DPIPE) return opNorm !(Tokens.DPIPE) (right);
	if (op == Tokens.NOT_EQUAL) return opNorm!(Tokens.NOT_EQUAL) (right);
	if (op == Tokens.DEQUAL) return opNorm!(Tokens.DEQUAL) (right);
	return null;
    }

    /**
     Operateur binaire pour le type bool.
     Params:
     op = l'operateur
     left = l'operande gauche de l'expression
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOpRight (Word op, Expression left) {
	if (op == Tokens.EQUAL) return AffectRight (left);
	return null;
    }

    /**
     Opérateur unaire.
     Params:
     op = l'operateur.
     Returns: le type résultat ou null.
     */
    override InfoType UnaryOp (Word op) {
	if (op == Tokens.NOT) {
	    auto ret = new BoolInfo ();
	    ret.lintInstS.insertBack (&BoolUtils.InstXor);
	    if (this._value)
		ret.value = this._value.UnaryOp (op);
	    return ret;
	} else if (op == Tokens.AND) return toPtr ();
	return null;
    }

    /**
     Récupère un pointeur sur le type bool, opérateur '&'.
     Returns: le type ptr!bool
     */
    private InfoType toPtr () {
	auto ptr = new PtrInfo ();
	ptr.content = new BoolInfo ();
	ptr.lintInstS.insertBack (&BoolUtils.InstAddr);
	return ptr;
    }

    /**
     Operateur '='.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType Affect (Expression right) {
	if (cast(BoolInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &BoolUtils.InstAffect;
	    return b;
	}
	return null;
    }

    /**
     Operateur '='.
     Params:
     left = l'operande gauche de l'expression.
     Returns: Le type résultat ou null.
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &BoolUtils.InstAffect;
	    return b;
	}
	return null;
    }

    /**
     Opérateur standart du type bool.
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: Le type résultat ou null.
     */
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast(BoolInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    if (this._value)
		b.value = this.value.BinaryOp(op, right.info.type.value);
	    b.lintInst = &BoolUtils.InstOp !(op);
	    return b;
	}
	return null;
    }

    /**
     Returns: le nom du type.
     */
    override string typeString () {
	return "bool";
    }

    /**
     Returns: le nom du type simplifié.
     */
    override string simpleTypeString () {
	return "b";
    }
    
    /**
     L'operateur '.'.
     Params:
     var = l'attribut auquel on veut accéder.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.token.str == "init") return Init ();
	else if (var.token.str == "sizeof") return SizeOf ();
	else if (var.token.str == "typeid") return StringOf ();
	return null;
    }

    /**
     La valeur d'initialisation d'un type bool (bool.init).
     Returns: un type bool.
     */
    private InfoType Init () {
	auto _bl = new BoolInfo ();
	_bl.lintInst = &BoolUtils.BoolInit;
	return _bl;
    }

    /**
     La taille d'un type bool (bool.sizeof).
     Returns: Un type int (TODO passer ça en type ubyte).
     */
    private InfoType SizeOf () {	
	auto _int = new DecimalInfo (DecimalConst.UBYTE);
	_int.lintInst = &BoolUtils.BoolSize;
	return _int;
    }

    /**
     Le nom du type bool (bool.typeid).
     Returns: un type string.
     */
    private InfoType StringOf () {
	auto str = new StringInfo ();
	str.value = new StringValue (this.typeString);
	return str;
    }
    
    /**
     Opérateur de cast.
     Params:
     other = le type vers lequel on essai de caster.
     Returns: le type résultat du cast ou null.
     */
    override InfoType CastOp (InfoType other) {
	if (cast(BoolInfo)other) return this;
	else if (cast (CharInfo) other) {
	    auto aux = new CharInfo;
	    aux.lintInstS.insertBack (&BoolUtils.InstCastChar);
	    return aux;
	} else if (auto ot = cast (DecimalInfo) other) {
	    auto aux = ot.clone ();
	    final switch (ot.type.id) {
	    case DecimalConst.BYTE.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.BYTE)); break;
	    case DecimalConst.UBYTE.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.UBYTE)); break;
	    case DecimalConst.SHORT.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.SHORT)); break;
	    case DecimalConst.USHORT.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.USHORT)); break;
	    case DecimalConst.INT.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.INT)); break;
	    case DecimalConst.UINT.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.UINT)); break;
	    case DecimalConst.LONG.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.LONG)); break;
	    case DecimalConst.ULONG.id : aux.lintInstS.insertBack (&BoolUtils.InstCast ! (DecimalConst.ULONG)); break;
	    }
	    return aux;
	}
	return null;
    }

    /**
     Opérateur de cast automatique.
     Params:
     other = le type vers lequel on essai de caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (cast (BoolInfo) other || cast (UndefInfo) other) {
	    auto bl = new BoolInfo;
	    bl.lintInst = &BoolUtils.InstAffect;
	    return bl;
	}
	return null;
    }

    /**
     Returns: une nouvelle instance du type bool.
     */
    override InfoType clone () {
	auto ret = new BoolInfo ();
	ret.value = this._value;
	return ret;
    }

    /**
     Returns: une nouvelle instance du type bool.
     */
    override InfoType cloneForParam () {
	return new BoolInfo ();
    }

    /**
     Returns: la taille en mémoire du type bool.
     */
    override LSize size () {
	return LSize.BYTE;
    }
    
}
