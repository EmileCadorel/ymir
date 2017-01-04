module semantic.types.PtrFuncInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.PtrFuncUtils, syntax.Keys;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;
import semantic.types.NullInfo, std.stdio;
import std.container, semantic.types.FunctionInfo, std.outbuffer;
import ast.ParamList, semantic.pack.Frame, semantic.types.StringInfo;

/**
 Classe d'information du type pointeur sur fonction.
 */
class PtrFuncInfo : InfoType {

    /** Les paramètres du pointeurs */
    private Array!InfoType _params;

    /** Le type de retour du pointeur */
    private InfoType _ret;

    /** Le score du pointeur (en cas d'appel, utile pour la génération de lint)*/
    private ApplicationScore _score;
    
    this () {
    }

    /**
     Params:
     other = le deuxieme type.
     Returns: les deux types sont identique ?
     */
    override bool isSame (InfoType other) {
	auto ptr = cast (PtrFuncInfo) other;
	if (ptr is null) return false;
	else {
	    if (!this._ret.isSame (ptr._ret)) return false;
	    foreach (it ; 0 .. this._params.length) {
		if (!ptr._params [it].isSame (this._params [it]))
		    return false;
	    }
	    return true;
	}
    }

    /**
     Créé un type ptr sur fonction en fonction des paramètre templates.
     Params:
     token = l'identifiant du créateur.
     templates = les attributs templates.
     Returns: Une instance de ptr sur fonction.
     Throws: UndefinedType
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length < 1)
	    throw new UndefinedType (token, "prend au moins un type en template");
	else {
	    auto ptr = new PtrFuncInfo ();
	    ptr._ret = templates [0].info.type;
	    if (templates.length > 1) {
		foreach (it ; 1 .. templates.length) {
		    ptr._params.insertBack (templates [it].info.type);
		}
	    }
	    return ptr;
	}
    }

    /**
     Surcharge des operateur binaire du pointeur sur fonction.
     Params:
     token = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	if (token == Keys.IS) return Is (right);
	if (token == Keys.NOT_IS) return NotIs (right);
	return null;
    }

    /**
     Surcharge des operateur binaire à droite du pointeur sur fonction.
     Params:
     token = l'operateur.
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	if (token == Keys.IS) return Is (left);
	if (token == Keys.NOT_IS) return NotIs (left);
	return null;
    }

    /**
     Operateur '='.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     Bugs: impossible d'affecter un pointeur identique.
     */
    private InfoType Affect (Expression right) {
	if (auto fun = cast (FunctionInfo) right.info.type) {
	    auto score = fun.CallOp (right.token, this._params);
	    if (score is null || !score.ret.isSame (this._ret)) return null;
	    auto ret = cast (PtrFuncInfo) this.clone ();
	    ret._score = score;
	    ret.lintInst = &PtrFuncUtils.InstAffect;
	    ret.rightTreatment = &PtrFuncUtils.InstConstFunc;
	    return ret;
	} else if (cast (NullInfo) right.info.type) {
	    auto ret = this.clone ();
	    ret.lintInst = &PtrFuncUtils.InstAffectNull;
	    return ret;
	}
	return null;
    }

    /**
     Operateur '=' à droite.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ret = new PtrFuncInfo ();
	    ret._ret = this._ret.clone ();
	    foreach (it ; this._params)
		ret._params.insertBack (it.clone ());
	    ret.lintInst = &PtrFuncUtils.InstAffect;
	    return ret;
	}
	return null;
    }

    /**
     Operateur 'is'.
     Params: 
     right = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType Is (Expression right) {
	if (cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstIs;
	    return ret;
	} else if (cast (PtrFuncInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstIs;
	    return ret;
	}
	return null;
    }

    
    /**
     Operateur '!is'.
     Params: 
     right = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType NotIs (Expression right) {
	if (cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstNotIs;
	    return ret;
	} else if (cast (PtrFuncInfo) right.info.type) {
	    auto ret = new BoolInfo ();
	    ret.lintInst = &PtrFuncUtils.InstNotIs;
	    return ret;
	}
	return null;
    }

    /**
     Returns: une nouvelle instance de ptr!function, l'information de score est conservé
     */
    override InfoType clone () {
	auto aux = new PtrFuncInfo ();
	foreach (it ; this._params) {
	    aux._params.insertBack (it.clone ());	    
	}
	aux._ret = this._ret.clone ();
	aux._score = this._score;
	return aux;
    }

    /**
     Returns: une nouvelle instance de ptr!function, l'information de score est remise à zéro
     */
    override InfoType cloneForParam () {
	auto aux = new PtrFuncInfo ();
	foreach (it ; this._params) {
	    aux._params.insertBack (it.clone ());	    
	}
	aux._ret = this._ret.clone ();
	return aux;
    }

    /**
     Returns: la taille mémoire du type
     */
    override LSize size () {
	return LSize.LONG;
    }

    /**
     Surcharge de l'operateur '()'
     Params:
     token = l'identificateur de l'appel.
     params = les parammètre de l'appel.
     Returns: le score résultat ou null, si non applicable.
     */
    override ApplicationScore CallOp (Word token, ParamList params) {
	if (params.params.length != this._params.length) {
	    return null;
	}
	
	auto score = new ApplicationScore (token);
	foreach (it ; 0 .. this._params.length) {
	    InfoType info = this._params [it];	    
	    auto type = params.params [it].info.type.CompOp (info);
	    if (type && type.isSame(info)) {
		score.score += Frame.SAME;
		score.treat.insertBack (type);
	    } else if (type !is null) {
		score.score += Frame.AFF;
		score.treat.insertBack (type);
	    } else return null;
	}
	
	auto ret = this._ret.cloneForParam ();
	score.dyn = true;
	score.ret = ret;
	return score;
    }

    /**
     Surcharge de l'operateur de cast automatique.
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (other.isSame (this) || cast (UndefInfo) other) {
	    auto ptr = this.clone ();
	    ptr.lintInst = &PtrFuncUtils.InstAffect;
	    return ptr;
	}
	return null;
    }

    /**
     Surcharge de l'operateur d'attribut.
     Params:
     var = l'attribut demandé.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") {
	    auto str = new StringInfo ();
	    str.lintInst = &PtrFuncUtils.StringOf;
	    str.leftTreatment = &PtrFuncUtils.GetStringOf;
	    return str;
	}
	return null;
    }    

    /**
     Returns: le nom du type.
     */
    override string typeString () {
	auto buf = new OutBuffer ();
	buf.write ("function(");
	foreach (it ; this._params) {
	    buf.write (it.typeString);
	    if (it != this._params [$ - 1])
		buf.write (",");
	}
	buf.writef ("):%s", this._ret.typeString);
	return buf.toString ();
    }

    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	auto buf = new OutBuffer;
	buf.write ("f_");
	foreach (it ; this._params) {
	    buf.write (it.simpleTypeString);
	}
	return buf.toString ();
    }
    
    /**
     Returns: le score du type (pour la transformation en lint).
     */
    ApplicationScore score () {
	return this._score;
    }
    
}
