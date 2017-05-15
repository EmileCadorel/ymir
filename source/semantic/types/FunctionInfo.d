module semantic.types.FunctionInfo;
import semantic.types.InfoType, utils.exception;
import ast.ParamList, std.container, semantic.pack.UnPureFrame;
import semantic.pack.Frame;
import std.stdio, syntax.Word;
import semantic.pack.FrameProto;
import ast.Expression;
import semantic.types.RefInfo;
import semantic.pack.Table;

/**
 Classe qui regroupe le information de type des déclarations de fonctions.
 */
class FunctionInfo : InfoType {

    /** Le nom des fonctions */
    private string _name;

    /** Le contexte du type */
    private string _namespace;

    /** Les différentes surcharge de fonction */
    private Array!Frame _infos;

    /**
     Params:
     namespace = le contexte du type
     name = le nom des surcharges de fonctions
     */
    this (string namespace, string name) {
	this._name = name;
	this._namespace = namespace;
    }

    this (string namespace, string name, Array!Frame infos) {
	this._name = name;
	this._namespace = namespace;
	this._infos = infos;
    }
    
    /**
     Returns: `false`
     */
    override bool isSame (InfoType) {
	return false;
    }

    /**
     Insert une nouvelle surcharge de fonction.
     Params:
     fr = une surcharge de fonction du même nom que le type.
     */
    void insert (Frame fr) {
	this._infos.insertBack (fr);
    }

    /**
     Returns: `this`.
     */
    override InfoType clone () {
	return this;
    }

    /**
     Throws: Assert, tout le temps.
     */
    override InfoType cloneForParam () {
	assert (false, "C'est quoi cette histoire, une fonction en parametre");
    }    

    /**
     Surcharge de l'operateur d'appel de la fonction (ici utilisé pour récupéré un pointeur sur fonction).
     Params:
     func_token = L'identifiant d'appel.
     params = les types des paramètres voulu pour la surcharge.
     Returns: un score ou null si non applicable.
     Throws: TemplateCreation
     */
    ApplicationScore CallOp (Word func_token, Array!InfoType  params) {
	ulong id = 0;
	Array!ApplicationScore total;
	try {
	    foreach (it ; 0 .. this._infos.length)
		total.insertBack (this._infos[it].isApplicable (params));
	    
	    Array!Frame goods;
	    ApplicationScore right = new ApplicationScore;
	    foreach (it ; 0 .. total.length) {
		if (total [it] !is null) {
		    if (goods.length == 0 && total [it].score != 0) {
			right = total[it];
			goods.insertBack (this._infos [it]);
		    } else if (right.score < total [it].score) {
			goods.clear ();
			goods.insertBack (this._infos [it]);
			right = total [it];
		    } else if (right.score == total [it].score && total [it].score != 0) {
			goods.insertBack (this._infos [it]);
		    }
		}
	    }

	    if (goods.length == 0) return null;
	    else if (goods.length != 1)
		throw new TemplateSpecialisation (goods [0].ident, goods [1].ident);

	    Table.instance.addCall (func_token);
	    auto info = goods[0].validate (right, right.treat);	    
	    right.name = info.name;
	    right.ret = info.type.type.cloneForParam ();
	    right.ret.value = info.type.value;
	    if (cast (RefInfo) right.ret)
		right.ret.isConst = false;
	    return right;
	} catch (RecursiveExpansion exp) {
	    throw exp;
	} catch (YmirException exp) {
	    if (cast(RecursiveExpansion) exp) throw exp;
	    exp.print ();
	    throw new TemplateCreation (func_token);
	} catch (ErrorOccurs err) {
	    auto a = new TemplateCreation (func_token);
	    a.print ();
	    throw err;
	}	
    }
    
    /**
     Surcharge de l'operateur d'appel de la fonction.
     Params:
     func_token = L'identifiant d'appel.
     params = les types des paramètres voulu pour la surcharge.
     Returns: un score ou null si non applicable.
     Throws: TemplateCreation
     */
    override ApplicationScore CallOp (Word func_token, ParamList params) {
	ulong id = 0;
	Array!ApplicationScore total;
	try {
	    foreach (it ; 0 .. this._infos.length)
		total.insertBack (this._infos[it].isApplicable (params));

	    Array!Frame goods;
	    ApplicationScore right = new ApplicationScore;
	    foreach (it ; 0 .. total.length) {
		if (total [it] !is null) {
		    if (goods.length == 0 && total [it].score != 0) {
			right = total[it];
			goods.insertBack (this._infos [it]);
		    } else if (right.score < total [it].score) {
			goods.clear ();
			goods.insertBack (this._infos [it]);
			right = total [it];
		    } else if (right.score == total [it].score && total [it].score != 0) {
			goods.insertBack (this._infos [it]);
		    }
		}
	    }

	    if (goods.length == 0) return null;
	    else if (goods.length > 1) {
		throw new TemplateSpecialisation (goods [0].ident, goods [1].ident);
	    }

	    Table.instance.addCall (func_token);
	    auto info = goods [0].validate (right, right.treat);
	    right.name = info.name;
	    right.ret = info.type.type.cloneForParam ();
	    right.ret.value = info.type.value;
	    if (cast (RefInfo) right.ret)
		right.ret.isConst = false;
	    return right;
	} catch (RecursiveExpansion exp) {
	    throw exp;
	} catch (YmirException exp) {
	    debug { throw exp; }
	    else {
		if (cast(RecursiveExpansion) exp) throw exp;
		exp.print ();
		throw new TemplateCreation (func_token);
	    }
	} catch (ErrorOccurs err) {
	    debug { throw err;}
	    else {
		auto a = new TemplateCreation (func_token);
		a.print ();
		throw err;
	    }
	}	
    }

    override InfoType UnaryOp (Word op) {
	if (op == Tokens.AND) return toPtr ();
	return null;
    }

    private InfoType toPtr () {
	import semantic.pack.PureFrame, semantic.types.PtrFuncInfo;
	if (this._infos.length == 1) {
	    auto fr = cast (PureFrame) this._infos [0];
	    if (!fr) return null;
	    auto proto = fr.validate ();
	    Array!InfoType params;
	    foreach (it ; proto.vars) {
		params.insertBack (it.info.type);
	    }
	    auto ret = proto.type.type;
	    auto ptr = new PtrFuncInfo ();
	    ptr.isConst = true;
	    ptr.params = params;
	    ptr.ret = ret;	    
	    ptr.score = this.CallOp (fr.ident, params);
	    
	    return ptr;
	} else return null;
    }
    
    override InfoType TempOp (Array!Expression params) {
	Array!Frame ret;
	foreach (it ; this._infos) {
	    auto aux = it.TempOp (params);
	    if (aux) ret.insertBack (aux);
	}
	
	if (ret.length != 0) {
	    return new FunctionInfo (this._namespace, this._name, ret);
	}
	return null;
    }    

    /**
     On quitte le scope, donc on supprime toutes les surcharges local à ce scope.
     Params:
     namespace = le contexte que l'on quitte.     
     */
    override void quit (string namespace) {
	for (auto it = 0; it < this._infos.length; it ++) {
	    if (this._infos [it].namespace == namespace) {		
		this._infos.linearRemove (this._infos[it .. it + 1]);
	    }
	}
    }

    /**
     Returns: le nom du type fonction
     */
    override string typeString () {
	import semantic.pack.Frame;
	return "function <" ~ Frame.demangle (this._namespace) ~ "." ~ Frame.demangle (this._name) ~ ">";
    }    

    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	return "f_";
    }

    /**
       Returns: la liste des prototypes de fonctions possible
     */
    string [Word] candidates () {
	string [Word] rets;
	foreach (it ; this._infos) {
	    rets [it.ident] = it.protoString;
	}
	return rets;
    }

}

