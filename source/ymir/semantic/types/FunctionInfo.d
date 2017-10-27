module ymir.semantic.types.FunctionInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.stdio, std.container;
import std.outbuffer, std.format;

/**
 Classe qui regroupe le information de type des déclarations de fonctions.
 */
class FunctionInfo : InfoType {

    /** Le nom des fonctions */
    private string _name;

    /** Le contexte du type */
    private Namespace _namespace;

    /** Les différentes surcharge de fonction */
    private Frame _infos;

    private Array!Frame _fromTemplates;

    /++ La fonction est autosuffisante ? +/
    private bool _alone = false;
    
    /**
     Params:
     namespace = le contexte du type
     name = le nom des surcharges de fonctions
     */
    this (Namespace namespace, string name) {
	super (true);
	this._name = name;
	this._namespace = namespace;
    }

    this (Namespace namespace, string name, Array!Frame infos) {
	super (true);
	this._name = name;
	this._namespace = namespace;
	this._fromTemplates = infos;
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
    void set (Frame fr) {
	this._infos = (fr);
    }

    /++
     Returns: La frame associé au symbol
     +/
    Frame frame () {
	return this._infos;
    }

    Namespace space () {
	return this._namespace;
    }
    
    /**
     Returns: `this`.
     */
    override InfoType clone () {
	return this;
    }

    override Expression toYmir () {
	assert (false);
    }

    /**
     Throws: Assert, tout le temps.
     */
    override InfoType cloneForParam () {
	assert (false, "C'est quoi cette histoire, une fonction en parametre");
    }    

    /++
     Récupère toutes les frames du même nom.
     +/
    Array!Frame getFrames () {
	if (this._alone) return make!(Array!Frame) (this._infos);	    	
	if (this._fromTemplates.length != 0) return this._fromTemplates;
	Array!Frame alls;
	auto others = Table.instance.getAll (this._name);
	foreach (it ; others) {
	    if (auto fun = cast (FunctionInfo) it.type)
		if (!fun._alone)
		    alls.insertBack (fun._infos);
	}
	return alls;
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
	    Array!Frame frames = getFrames ();
	    foreach (it ; 0 .. frames.length)
		total.insertBack (frames[it].isApplicable (params));

	    writeln (func_token, " ", total.length);
	    Array!Frame goods;
	    ApplicationScore right = new ApplicationScore;
	    foreach (it ; 0 .. total.length) {		
		if (total [it] !is null) {
		    writeln ("\t ", total [it].score);
		    if (goods.length == 0 && total [it].score != 0) {
			right = total[it];
			goods.insertBack (frames [it]);
		    } else if (right.score < total [it].score) {
			goods.clear ();
			goods.insertBack (frames [it]);
			right = total [it];
		    } else if (right.score == total [it].score && total [it].score != 0) {
			goods.insertBack (frames [it]);
		    }
		}
	    }

	    if (goods.length == 0) return null;
	    else if (goods.length != 1)
		throw new TemplateSpecialisation (goods [0].ident, goods [1].ident);

	    Table.instance.addCall (func_token);
	    FrameProto info;
	    if (right.toValidate) {
		info = right.toValidate.validate (right, right.treat);
		right.name = Mangler.mangle!"functionv" (info.name, info);		
	    } else {
		info = goods [0].validate (right, right.treat);
		right.name = Mangler.mangle!"function" (info.name, info);
	    }

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
	    auto frames = getFrames ();
	    foreach (it ; 0 .. frames.length) 
		total.insertBack (frames [it].isApplicable (params));	    

	    writeln (func_token, " ", total.length);
	    Array!Frame goods;
	    ApplicationScore right = new ApplicationScore;
	    foreach (it ; 0 .. total.length) {
		if (total [it] !is null) {
		    writeln ("\t ", total [it].score, " ", frames [it]);
		    if (goods.length == 0 && total [it].score != 0) {
			right = total[it];
			goods.insertBack (frames [it]);
		    } else if (right.score < total [it].score) {
			goods.clear ();
			goods.insertBack (frames [it]);
			right = total [it];
		    } else if (right.score == total [it].score && total [it].score != 0) {
			goods.insertBack (frames [it]);
		    }
		}
	    }
	    
	    if (goods.length == 0) return null;
	    else if (goods.length > 1) {
		throw new TemplateSpecialisation (goods [0].ident, goods [1].ident);
	    }
	    
	    Table.instance.addCall (func_token);
	    FrameProto info;
	    if (right.toValidate) {
		info = right.toValidate.validate (right, right.treat);
		right.name = Mangler.mangle!"functionv" (info.name, info);
	    } else {
		info = goods [0].validate (right, right.treat);
		right.name = Mangler.mangle!"function" (info.name, info);
	    }
	    
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
	auto frames = getFrames ();
	if (frames.length == 1) {
	    auto fr = cast (PureFrame) frames [0];
	    if (!fr) return null;
	    auto proto = fr.validate ();
	    Array!InfoType params;
	    foreach (it ; proto.vars) {
		params.insertBack (it.info.type);
	    }
	    auto ret = proto.type.type;
	    auto ptr = new PtrFuncInfo (true);
	    ptr.params = params;
	    ptr.ret = ret;	    
	    ptr.score = this.CallOp (fr.ident, params);
	    
	    return ptr;
	} else return null;
    }
    
    override InfoType TempOp (Array!Expression params) {
	auto frames = getFrames ();
	Array!Frame ret;	
	foreach (it ; frames) {
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
    override void quit (Namespace) {
    }

    /**
     Returns: le nom du type fonction
     */
    override string innerTypeString () {
	auto frames = this.getFrames ();
	if (frames.length == 1 && frames [0].func) {
	    auto buf = new OutBuffer ();
	    buf.writef ("%s.%s(", this._namespace.toString, this._name);
	    foreach (it; 0 .. frames [0].func.params.length) {
		buf.writef ("%s%s",
			    frames [0].func.params [it].prettyPrint,
			    it < frames [0].func.params.length - 1 ? ", " : "");
	    }
	    buf.writef (")");
	    if (frames [0].func.type) 
		buf.writef ("->%s", frames [0].func.type.prettyPrint);
	    else
		buf.writef ("-> undef");
	    return buf.toString ();
	} else {
	    return format ("function <%s.%s>", this._namespace.toString, this._name);
	}
    }    

    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	return "F";
    }

    /**
       Returns: la liste des prototypes de fonctions possible
     */
    string [Word] candidates () {
	string [Word] rets;
	auto frames = getFrames ();
	foreach (it ; frames) {
	    rets [it.ident] = it.protoString;
	}
	return rets;
    }

    override bool isScopable () {
	return true;
    }

    ref bool alone () {
	return this._alone;
    }

    string name () {
	return this._name;
    }
    
}


