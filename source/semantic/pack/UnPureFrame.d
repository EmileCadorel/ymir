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


    override ApplicationScore isApplicable (ParamList params) {
	if (params.length > this._function.params.length) return this.isApplicableVariadic (params);
	else return super.isApplicable (params);
	
    }

    override ApplicationScore isApplicable (Array!InfoType params) {
	if (params.length > this._function.params.length) return this.isApplicableVariadic (params);
	else return super.isApplicable (params);
    }

    private ApplicationScore isApplicableVariadic (ParamList params) {
	if (this._function.params.length == 0 || cast (TypedVar) this._function.params [$ - 1]) 
	    return null;
	else {
	    auto ftype = params.paramTypes;	    
	    auto types = make!(Array!InfoType) (ftype [0 .. this._function.params.length]);
	    
	    auto score = super.isApplicable (this._function.ident, this._function.params, types);
	    if (score is null || score.score == 0) return score;
	    auto tuple = new TupleInfo ();
	    auto last = score.treat.back ();
	    auto tuple_types = make!(Array!InfoType) (ftype [this._function.params.length - 1 .. $]);
	    
	    tuple.params = tuple_types;
	    score.treat.back () = tuple;
	    score.score += AFF - CHANGE;
	    return score;
	}
    }

    private ApplicationScore isApplicableVariadic (Array!InfoType params) {
	if (this._function.params.length == 0 || cast (TypedVar) this._function.params [$ - 1]) 
	    return null;
	else {
	    return null;
	}
    }

    
    /**
     Analyse sémantique de la frame.
     Params:
     params = Les informations de type à appliqué à la frame.
     Returns: le prototype de la frame analysé.
     */
    override FrameProto validate (Array!InfoType params) {
	Table.instance.enterFrame (Table.instance.globalNamespace, this._name, this._function.params.length, this._isInternal);
	Table.instance.enterBlock ();
	
	Array!Var finalParams = Frame.computeParams (this._function.params, params);
	return super.validate (Table.instance.globalNamespace, finalParams);
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
