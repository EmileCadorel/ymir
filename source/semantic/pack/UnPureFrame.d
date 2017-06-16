module semantic.pack.UnPureFrame;
import ast.Function, semantic.types.InfoType;
import ast.ParamList, semantic.pack.Frame;
import std.container, ast.Var, std.conv;
import semantic.pack.Table, semantic.pack.Symbol;
import semantic.types.UndefInfo, semantic.types.VoidInfo;
import semantic.pack.FrameTable, syntax.Word;
import semantic.pack.FrameProto;
import semantic.pack.FinalFrame;
import semantic.types.TupleInfo;
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
	return super.validate (this._namespace, Table.instance.globalNamespace, finalParams, this._isVariadic);
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
