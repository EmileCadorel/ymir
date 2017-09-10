module ymir.semantic.pack.UnPureFrame;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;

import std.container, std.conv;
import std.stdio, std.array;

/**
 Cette classe est une instance de frame impure.
 */
class UnPureFrame : Frame {

    /** Le nom de la frame */
    private string _name;    
    
    /**
     Params:
     namespace = le contexte de la frame.
     func = la fonction associé à la frame.
     */
    this (Namespace namespace, Function func) {
	super (namespace, func);
	this._name = func.ident.str;
    }
    
    /**
     Analyse sémantique de la frame.
     Params:
     params = Les informations de type à appliqué à la frame.
     Returns: le prototype de la frame analysé.
     */
    override FrameProto validate (Array!InfoType params) {
	Table.instance.enterFrame (this._namespace, this._name, this._function.params.length, this._isInternal);
	Table.instance.enterBlock ();

	Array!Var finalParams = Frame.computeParams (this._function.params, params);
	Namespace from = Table.instance.globalNamespace;
	if (this._imutSpace) 
	    from = new Namespace (from, this._imutSpace);	
	return super.validate (this._namespace, from, finalParams, this._isVariadic);
    }    
    
    /**
     Analyse sémantique de la frame.
     Params:
     params = Les informations de type à appliqué à la frame.
     Returns: le prototype de la frame analysé.
    */
    override FrameProto validate (ParamList params) {
	return this.validate (params.paramTypes);
    }
    
}
