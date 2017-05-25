module semantic.pack.ExternFrame;
import semantic.types.InfoType;
import ast.ParamList, semantic.pack.Frame;
import std.container, ast.Var, std.conv;
import semantic.pack.Table, semantic.pack.Symbol;
import semantic.types.UndefInfo, semantic.types.VoidInfo;
import semantic.pack.FrameTable, syntax.Word, ast.Proto;
import ast.Function, semantic.pack.PureFrame, semantic.pack.FrameProto;

/**
 Les frames externs sont uniquement des prototypes, elle sont obtenu pas import, ou déclaration. 
 */
class ExternFrame : Frame {

    /** Le nom de la frame */
    private string _name;

    /** Le protocole de la frame */
    private Proto _proto;
    
    /** L'identifiant de mangling (si 'C' aucun mangle ne sera fait) */
    private string _from;

    /** Le protocole créé à la sémantique */
    private FrameProto _fr;

    /** 
     Params:
     namespace = le contexte du prototype
     from = l'information pour le mangling
     func = le prototype
    */
    this (Namespace namespace, string from, Proto func) {
	super (namespace, null);
	this._name = func.ident.str;
	this._from = from;
	this._proto = func;
    }

    this (Namespace namespace, Function func) {
	super (namespace, func);
	this._name = func.ident.str;
	this._proto = null;
    }

        
    /**
     Le prototype de fonction peut-il servir à l'appel 
     Params:
     params = les paramètres de l'appel
     Returns: Un score d'application (null si non applicable)
     */
    override ApplicationScore isApplicable (ParamList params) {
	if (this._proto is null) return super.isApplicable (params);
	if (this._proto.isVariadic) return isApplicableVariadic (params);
	else return super.isApplicable (this._proto.ident, this._proto.params, params.paramTypes);
    }

    /**
     Validation d'un prototype de fonction variadice
     Params:
     params = les paramètres passé à l'appel de la fonction
     Returns: le score d'application (null si non applicable)
     */
    private ApplicationScore isApplicableVariadic (ParamList params) {	
	auto ftypes = params.paramTypes;
	Array!InfoType types;
	if (ftypes.length >= this._proto.params.length)	    
	    types = make!(Array!InfoType) (ftypes [0 .. this._proto.params.length]);
	else types = ftypes;
	auto ret = super.isApplicable (this._proto.ident, this._proto.params, types);
	if (ret !is null) {	
	    foreach (it ; this._proto.params.length .. ftypes.length) {
		ret.score += SAME;
		ret.treat.insertBack (null);
	    }
	}
	
	return ret;
    }

    
    /**
     Créée le prototype pour la génération de code intérmédiaire.
     Returns: le prototype de fonction, avec le nom manglé (ou non si this._from = 'C')
     */
    override FrameProto validate () {
	if (this._proto is null) return validateFunc ();
	Table.instance.enterFrame (this._namespace, this._name, this._proto.params.length, this._isInternal);
	Array!Var finalParams = Frame.computeParams (this._proto.params);	
	Table.instance.setCurrentSpace (this._namespace, this._name);
	
	if (this._proto.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof (), new VoidInfo ());
	} else {
	    Table.instance.retInfo.info = this._proto.type.asType ().info;
	}
	    
	this._fr = new FrameProto (this._name, this._namespace, Table.instance.retInfo.info, finalParams, this._tempParams);
	if (this._from == "C") this._fr.externC = true;
	Table.instance.quitFrame ();
	return this._fr;
    }


    /**
     Validation d'un frame externe à partir d'une fonction.
     Returns: le prototype de fonction, avec le nom manglé.
     */
    FrameProto validateFunc () {	
	Table.instance.enterFrame (this._namespace, this._name, this._function.params.length, this._isInternal);
	Array!Var finalParams = Frame.computeParams (this._function.params);       
	Table.instance.setCurrentSpace (this._namespace, this._name);
	
	if (this._function.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof, new VoidInfo ());
	} else {
	    Table.instance.retInfo.info = this._function.type.asType ().info;
	}
	
	this._fr = new FrameProto (this._name, this._namespace, Table.instance.retInfo.info, finalParams, this._tempParams);
	
	if (this._from == "C") this._fr.externC = true;
	Table.instance.quitFrame ();
	return this._fr;
    }
    
    /**
     Créée le prototype pour la génération de code intérmédiaire.
     Returns: le prototype de fonction, avec le nom manglé (ou non si this._from = 'C')
    */
    override FrameProto validate (ParamList) {
	return validate ();
    }

    /**
     Créée le prototype pour la génération de code intérmédiaire.
     Returns: le prototype de fonction, avec le nom manglé (ou non si this._from = 'C')
    */
    override FrameProto validate (Array!InfoType) {
	return validate ();
    }
    
    /**
     Returns: l'identifiant du prototype
     */
    override Word ident () {
	if (this._proto is null) return super.ident ();
	return this._proto.ident;
    }

    override string protoString () {
	import std.outbuffer;
	if (this._function) return super.protoString ();
	else {	   
	    auto buf = new OutBuffer ();
	    buf.writef("def %s.%s ", this._namespace.toString, this._name);
	    if (this._from !is null && this._from != "") {
		buf.writef ("(%s)", this._from);
	    }
	    buf.writef ("(");
	    foreach (it ; this._proto.params) {
		buf.writef ("%s", it.prettyPrint);
		if (it !is this._proto.params [$ - 1])
		    buf.writef (", ");
	    }
	    buf.writef (")");
	    if (this._proto.type) {
		buf.writef (" : %s",this._proto.type.prettyPrint);
	    }
	    return buf.toString ();
	}
	
    }

    
}    
