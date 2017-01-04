module semantic.types.FloatInfo;
import syntax.Word, ast.Expression, semantic.types.FloatUtils;
import syntax.Tokens;
import semantic.types.InfoType, utils.exception;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo;
import lint.LSize, ast.Var, ast.Constante;
import semantic.types.StringInfo, semantic.types.LongInfo;

/**
 Cette classe regroupe les informations de type du type float.
 */
class FloatInfo : InfoType {

    /**
     Créé un instance de type float à partir d'un instancation de type.
     Pour fonctionner, templates doit être vide.
     Params:
     token = l'identifiant du declarateur du float.
     templates = les templates de l'identifiant.
     Returns: Une instance de type float.
     Throws: NotATemplate
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new FloatInfo ();
    }

    /**
     Params:
     other = le deuxieme type.
     Returns: le deux type sont il identique ?
     */
    override bool isSame (InfoType other) {
	return (cast (FloatInfo) other) !is null;
    }

    /**
     La surcharge des operateur binaire du type float.
     Params:
     token = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	if (token == Tokens.DIV_AFF) return opAff! (Tokens.DIV) (right);
	if (token == Tokens.STAR_EQUAL) return opAff! (Tokens.STAR) (right);
	if (token == Tokens.MINUS_AFF) return opAff! (Tokens.MINUS) (right);
	if (token == Tokens.PLUS_AFF) return opAff! (Tokens.PLUS) (right);
	if (token == Tokens.INF) return opTest! (Tokens.INF) (right);	
	if (token == Tokens.SUP) return opTest! (Tokens.SUP) (right);
	if (token == Tokens.INF_EQUAL) return opTest! (Tokens.INF_EQUAL) (right);
	if (token == Tokens.SUP_EQUAL) return opTest! (Tokens.SUP_EQUAL) (right);
	if (token == Tokens.NOT_EQUAL) return opTest! (Tokens.NOT_EQUAL) (right);
	if (token == Tokens.NOT_INF) return opTest! (Tokens.SUP_EQUAL) (right);
	if (token == Tokens.NOT_INF_EQUAL) return opTest! (Tokens.SUP) (right);
	if (token == Tokens.NOT_SUP) return opTest! (Tokens.INF_EQUAL) (right);
	if (token == Tokens.NOT_SUP_EQUAL) return opTest! (Tokens.INF) (right);
	if (token == Tokens.DEQUAL) return opTest! (Tokens.DEQUAL) (right);
	if (token == Tokens.PLUS) return opNorm! (Tokens.PLUS) (right);
	if (token == Tokens.MINUS) return opNorm! (Tokens.MINUS) (right);
	if (token == Tokens.DIV) return opNorm! (Tokens.DIV) (right);
	if (token == Tokens.STAR) return opNorm! (Tokens.STAR) (right);
	return null;
    }

    /**
     La surcharge des operateur binaire droits du type float.
     Params:
     token = l'operateur.
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	if (token == Tokens.INF) return opTestRight! (Tokens.INF) (left);	
	if (token == Tokens.SUP) return opTestRight! (Tokens.SUP) (left);
	if (token == Tokens.INF_EQUAL) return opTestRight! (Tokens.INF_EQUAL) (left);
	if (token == Tokens.SUP_EQUAL) return opTestRight! (Tokens.SUP_EQUAL) (left);
	if (token == Tokens.NOT_EQUAL) return opTestRight! (Tokens.NOT_EQUAL) (left);
	if (token == Tokens.NOT_INF) return opTestRight! (Tokens.SUP_EQUAL) (left);
	if (token == Tokens.NOT_INF_EQUAL) return opTestRight! (Tokens.SUP) (left);
	if (token == Tokens.NOT_SUP) return opTestRight! (Tokens.INF_EQUAL) (left);
	if (token == Tokens.NOT_SUP_EQUAL) return opTestRight! (Tokens.INF) (left);
	if (token == Tokens.DEQUAL) return opTestRight! (Tokens.DEQUAL) (left);
	if (token == Tokens.PLUS) return opNormRight! (Tokens.PLUS) (left);
	if (token == Tokens.MINUS) return opNormRight! (Tokens.MINUS) (left);
	if (token == Tokens.DIV) return opNormRight! (Tokens.DIV) (left);
	if (token == Tokens.STAR) return opNormRight! (Tokens.STAR) (left);
	return null;
    }

    /**
     Operateur '='.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType Affect (Expression right) {
	if (cast(FloatInfo)right.info.type) {
	    auto f = new FloatInfo ();
	    f.lintInst = &FloatUtils.InstAffect;
	    return f;
	} else if (cast (IntInfo) right.info.type) {
	    auto f = new FloatInfo ();
	    f.lintInst = &FloatUtils.InstAffectInt;
	    return f;
	}
	return null;
    }

    /**
     Operateur '=' droit.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstAffect;
	    return fl;
	}
	return null;
    }

    /**
     Operateur de cast du type float.
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CastOp (InfoType other) {
	if (cast(FloatInfo)other !is null) return this;
	else if (cast (LongInfo) other !is null) {
	    auto l = new LongInfo ();
	    l.lintInstS.insertBack (&FloatUtils.InstCastLong);
	    return l;
	} else if (cast (IntInfo) other !is null) {
	    auto i = new IntInfo ();
	    i.lintInstS.insertBack (&FloatUtils.InstCastInt);
	    return i;
	}
	return null;
    }

    /**
     Opérateur de cast automatique.
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || cast (FloatInfo) other) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstAffect;
	    return fl;
	}
	return null;
    }

    /**
     Opérateur unaire du type float.
     Params:
     op = l'operateur.
     Returns: le type résultat ou null.
     */
    override InfoType UnaryOp (Word op) {
	if (op == Tokens.MINUS) return Inv ();
	return null;
    }

    /**
     Operateur unaire '-'.
     Returns: un type float.
     */
    private InfoType Inv () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&FloatUtils.InstInv);
	return ret;
    }

    /**
     Operateur '.'.
     Params:
     var = l'attribut auquel on veut accéder.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.token.str == "init") return Init ();
	else if (var.token.str == "max") return Max ();
	else if (var.token.str == "min") return Min ();
	else if (var.token.str == "nan") return Nan ();
	else if (var.token.str == "dig") return Dig ();
	else if (var.token.str == "epsilon") return Epsilon ();
	else if (var.token.str == "mant_dig") return MantDig ();
	else if (var.token.str == "max_10_exp") return Max10Exp ();
	else if (var.token.str == "max_exp") return MaxExp ();
	else if (var.token.str == "min_10_exp") return Min10Exp ();
	else if (var.token.str == "min_exp") return MinExp ();
	else if (var.token.str == "infinity") return Inf ();
	else if (var.token.str == "typeid") return StringOf ();
	else if (var.token.str == "sqrt") return Sqrt ();
	return null;
    }


    /**
     La constante d'init de float (float.init).
     Returns: un type float.
     */
    private InfoType Init () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.FloatInit;
	return fl;
    }
    
    /**
     La constante max de float (float.max).
     Returns: un type float.
    */
    private InfoType Max () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Max;
	return fl;
    }
    
    /**
     La constante min de float (float.min).
     Returns: un type float.
     */
    private InfoType Min () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Min;
	return fl;
    }
    
    /**
     La constante nan de float (float.nan).
     Returns: un type float.
     */
    private InfoType Nan () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Nan;
	return fl;
    }
    
    /**
     La constante dig de float (float.dig).
     Returns: un type int.
     */
    private InfoType Dig () {
	auto fl = new IntInfo ();
	fl.lintInst = &FloatUtils.Dig;
	return fl;
    }

    /**
     La constante epsilon de float (float.epsilon).
     Returns: un type float.
     */
    private InfoType Epsilon () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Epsilon;
	return fl;
    }

    /**
     La constante mant_dig de float (float.mant_dig).
     Returns: un type int.
     */
    private InfoType MantDig () {
	auto fl = new IntInfo ();
	fl.lintInst = &FloatUtils.MantDig;
	return fl;
    }

    /**
     La constante max_10_exp de float (float.max_10_exp).
     Returns: un type float.
    */
    private InfoType Max10Exp () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Max10Exp;
	return fl;
    }

    /**
     La constante max_exp de float (float.max_exp).
     Returns: un type float.
    */
    private InfoType MaxExp () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.MaxExp;
	return fl;
    }

    /**
     La constante min_exp de float (float.min_exp).
     Returns: un type float.
    */
    private InfoType MinExp () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.MinExp;
	return fl;
    }

    /**
     La constante min_10_exp de float (float.min_10_exp).
     Returns: un type float.
    */
    private InfoType Min10Exp () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Min10Exp;
	return fl;
    }

    /**
     La constante infini de float (float.infinity).
     Returns: un type float.
    */
    private InfoType Inf () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Inf;
	return fl;
    }

    /**
     La variable racine carre de float (float.sqrt).
     Returns: un type float.
    */
    private InfoType Sqrt () {
	auto fl = new FloatInfo ();
	fl.lintInst = &FloatUtils.Sqrt;
	return fl;
    }

    /**
     La constante nom de float (float.typeid).
     Returns: un type string.
    */
    private InfoType StringOf () {
	auto str = new StringInfo ();
	str.lintInst = &FloatUtils.FloatStringOf;
	str.leftTreatment = &FloatUtils.FloatGetStringOf;
	return str;
    }

    /**
     Les operateur d'affectation du type float.
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
    */
    private InfoType opAff (Tokens op) (Expression right) {
	if (cast (FloatInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOpAff ! (op);
	    return fl;
	}
	return null;
    }    

    /**
     Les autres operateur du type float.
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
    */
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast (FloatInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOp ! (op);
	    return fl;
	} else if (cast (IntInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOpInt !(op);
	    return fl;
	} else if (cast (LongInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOpInt !(op);
	    return fl;
	}
	return null;
    }
    
    /**
     Les operateurs de tests du type float.
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
    */
    private InfoType opTest (Tokens op) (Expression right) {
	if (cast (FloatInfo) right.info.type) {
	    auto bl = new BoolInfo ();
	    bl.lintInst = &FloatUtils.InstOpTest ! (op);
	    return bl;
	} else if (cast (IntInfo) right.info.type) {
	    auto bl = new BoolInfo ();
	    bl.lintInst = &FloatUtils.InstOpTestInt !(op);
	    return bl;
	}
	return null;
    }

    /**
     Les autres operateurs droits du type float.
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
    */
    private InfoType opNormRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto fl = new FloatInfo ();
	    fl.lintInst = &FloatUtils.InstOpIntRight !(op);
	    return fl;
	}
	return null;
    }
    
    /**
     Les operateurs de test droits du type float.
     Params:
     op = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
    */
    private InfoType opTestRight (Tokens op) (Expression right) {
	if (cast (IntInfo) right.info.type) {
	    auto bl = new BoolInfo ();
	    bl.lintInst = &FloatUtils.InstOpTestIntRight !(op);
	    return bl;
	}
	return null;
    }
    
    /**
     Returns: le nom du type float
     */
    override string typeString () {
	return "float";
    }

    /**
     Returns: le nom du type float simplifié.
     */
    override string simpleTypeString () {
	return "f";
    }
    
    /**
     Returns: une nouvelle instance de float
     */
    override InfoType clone () {
	return new FloatInfo ();
    }

    /**
     Returns: une nouvelle instance de float
    */
    override InfoType cloneForParam () {
	return new FloatInfo ();
    }

    /**
     La taille en mémoire du type float.
     */
    override LSize size () {
	return LSize.DOUBLE;
    }
    
}
