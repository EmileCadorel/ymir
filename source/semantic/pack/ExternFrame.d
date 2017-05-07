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

    /** Le namespace de la frame (module et fonction parent) */
    private string _namespace;

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
    this (string namespace, string from, Proto func) {
	super (namespace, null);
	this._name = func.ident.str;
	this._from = from;
	this._proto = func;
	this._namespace = namespace;
    }

    this (string namespace, Function func) {
	super (namespace, func);
	this._name = func.ident.str;
	this._proto = null;
	this._namespace = namespace;
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
	string name = this._name;
	if (this._from is null || this._from != "C") {
	    name = this._namespace ~ to!string (this._name.length) ~ super.mangle (this._name);
	    name = "_YN" ~ to!string (name.length) ~ name;
	}
	
	Table.instance.enterFrame (name, this._proto.params.length, this._isInternal);

	Array!Var finalParams;
	foreach (it ; 0 .. this._proto.params.length) {
	    auto info = this._proto.params [it].expression;
	    finalParams.insertBack (info);
	    finalParams.back ().info.id = it + 1;
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    if (name != "main" && (this._from is null || this._from != "C"))
		name ~= super.mangle (t);
	}
	    
	    
	Table.instance.setCurrentSpace (name);
	
	if (this._proto.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof (), new VoidInfo ());
	} else {
	    Table.instance.retInfo.info = this._proto.type.asType ().info;
	}
	    
	this._fr = new FrameProto (name, name, Table.instance.retInfo.info, finalParams);
	Table.instance.quitFrame ();
	return this._fr;
    }


    /**
     Validation d'un frame externe à partir d'une fonction.
     Returns: le prototype de fonction, avec le nom manglé.
     */
    FrameProto validateFunc () {
	string name = this._namespace ~ to!string (this._name.length) ~ super.mangle (this._name);
	name = "_YN" ~ to!string (name.length) ~ name;
	
	Table.instance.enterFrame (name, this._function.params.length, this._isInternal);
	Array!Var finalParams;
	foreach (it ; 0 .. this._function.params.length) {
	    auto info = this._function.params [it].expression;
	    finalParams.insertBack (info);
	    finalParams.back ().info.id = it + 1;
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    if (name != "main" && (this._from is null || this._from != "C"))
		name ~= super.mangle (t);	    
	}
	
	Table.instance.setCurrentSpace (name);
	if (this._function.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof, new VoidInfo ());
	} else {
	    Table.instance.retInfo.info = this._function.type.asType ().info;
	}
	
	this._fr = new FrameProto (name, name, Table.instance.retInfo.info, finalParams);
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
	    buf.writef("def %s.%s ", super.demangle (this._namespace), this._name);
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
