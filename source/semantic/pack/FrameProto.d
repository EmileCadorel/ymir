module semantic.pack.FrameProto;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.InfoType, semantic.pack.FrameScope;
import semantic.pack.Namespace;



/**
 Classe contenant un prototype de frame.
 Généré à l'analyse sémantique
 */
class FrameProto {

    /++
     L'emplacement de la création du prototype.
     +/
    private Namespace _namespace;
    
    /** Le nom de la frame */
    private string _name;

    /** Le type de retour de la frame */
    private Symbol _type;

    /** Les paramètres de la frame */
    private Array!Var _vars;

    /++ les paramètres qui ont permis la validation de la frame +/
    private Array!Expression _tmps;

    /++ Fonction externe C qui ne doit pas être manglé +/
    private bool _externC;
    
    this (string name, Namespace space, Symbol type, Array!Var params, Array!Expression tmps) {
	this._name = name;
	this._namespace = space;
	this._type = type;
	this._vars = params;
	this._tmps = tmps;
    }

    /**
     Returns: le nom de la frame
     */
    ref string name () {
	return this._name;	
    }

    /++
     Returns: le namespace du proto.
     +/
    Namespace namespace () {
	return this._namespace;
    }
    
    /**
     Returns: le type de retour de la frame
     */
    ref Symbol type () {
	return this._type;
    }

    /**
     Returns: La liste de paramètres de la frame
     */
    ref Array!Var vars () {
	return this._vars;
    }       

    ref bool externC () {
	return this._externC;
    }
    
    /++
     Returns: les templates qui on permis la validation de la frame.
     +/
    ref Array!Expression tmps () {
	return this._tmps;
    }
    
    override bool opEquals (Object other) {
	if (auto proto = cast (FrameProto) other) {
	    if (this._namespace != proto.namespace) return false;
	    if (this._name != proto.name) return false;
	    if (this._tmps.length != proto._tmps.length ||
		this._vars.length != proto._vars.length) return false;
	    
	    foreach (it ; 0 .. this._tmps.length) {
		if (this._tmps [it].info.value && proto._tmps[it].info.value) {
		    if (this._tmps [it].info.value.toString !=
			proto._tmps [it].info.value.toString) return false;
		} else if (this._tmps [it].info.value && !proto._tmps[it].info.value) {
		    return false;
		} else if (!this._tmps [it].info.value && proto._tmps[it].info.value) {
		    return false;
		} else {
		    if (!this._tmps [it].info.type.isSame (proto._tmps [it].info.type))
			return false;
		}
	    }
	    
	    foreach (it ; 0 .. this._vars.length) 
		if (this._vars [it].info.type.simpleTypeString !=
		    proto._vars [it].info.type.simpleTypeString) return false;
	    return true;
	}
	return false;
    }

    override string toString () {
	return this._namespace.toString ~ "." ~ this._name;
    }
    
    
}

