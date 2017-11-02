module ymir.semantic.pack.ExternFrame;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;

import std.container;

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

    private static Array!ExternFrame __extFrames__;
    
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
	__extFrames__.insertBack (this);
    }

    this (Namespace namespace, Function func) {
	super (namespace, func);
	this._name = func.ident.str;
	this._proto = null;
	__extFrames__.insertBack (this);
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
	auto ancpSpace = Table.instance.programNamespace;
	Table.instance.enterFrame (this._namespace, this._name, this._proto.params.length, this._isInternal);
	Array!Var finalParams = Frame.computeParams (this._proto.params);	
	Table.instance.setCurrentSpace (this._namespace, this._name);
	Table.instance.programNamespace = this._namespace;
	
	if (this._proto.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof (), new VoidInfo ());
	} else {
	    Table.instance.retInfo.info = this._proto.type.asType ().info;
	}
	    
	this._fr = new FrameProto (this._name, this._namespace, Table.instance.retInfo.info, finalParams, this._tempParams);
	
	this._fr.externName = this._from;
	Table.instance.quitFrame ();
	Table.instance.programNamespace = ancpSpace;
	return this._fr;
    }


    /**
     Validation d'un frame externe à partir d'une fonction.
     Returns: le prototype de fonction, avec le nom manglé.
     */
    FrameProto validateFunc () {	
	Table.instance.enterFrame (this._namespace, this._name, this._function.params.length, this._isInternal);
	Array!Var finalParams = Frame.computeParams (this._function.params);
	auto ancpSpace = Table.instance.programNamespace;
	Table.instance.setCurrentSpace (this._namespace, this._name);
	Table.instance.programNamespace = this._namespace;
	
	if (this._function.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof, new VoidInfo ());
	} else {
	    Table.instance.retInfo.info = this._function.type.asType ().info;
	}
	
	this._fr = new FrameProto (this._name, this._namespace, Table.instance.retInfo.info, finalParams, this._tempParams);
	
	this._fr.externName = this._from;
	
	Table.instance.quitFrame ();
	Table.instance.programNamespace = ancpSpace;
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
    
    static Array!ExternFrame frames () {
	return __extFrames__;
    }

    static void clear () {
	__extFrames__ = make!(Array!ExternFrame) ();
    }
    
    /**
     Returns: l'identifiant du prototype
     */
    override Word ident () {
	if (this._proto is null) return super.ident ();
	return this._proto.ident;
    }
    
    bool isFromC () {
	return this._from == "C";
    }

    bool isFromD () {
	return this._from == "D";
    }

    bool isFromY () {
	return  this._from == "";
    }

    string from () {
	return this._from;
    }

    FrameProto proto () {
	return this._fr;
    }

    string name () {
	return this._name;
    }

    override bool isVariadic () {
	if (this._proto)
	    return this._proto.isVariadic;
	else return false;
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
