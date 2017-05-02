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
    this (string namespace, Function func) {
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
	string name = Table.instance.globalNamespace ~ to!string (this._name.length) ~ super.mangle (this._name);
	string un = Table.instance.globalNamespace ~ to!string (this._name.length) ~ this._name;
	name = "_YN" ~ to!string (name.length) ~ name;
	
	Table.instance.enterFrame (name, this._function.params.length);
	Table.instance.enterBlock ();
	
	Array!Var finalParams;
	foreach (it; 0 .. this._function.params.length) {
	    if (cast(TypedVar)this._function.params [it] is null) {
		auto var = this._function.params [it].setType (params [it]);   
		finalParams.insertBack (var.expression);
	    } else finalParams.insertBack (this._function.params [it].expression);
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    finalParams.back ().info.id = it + 1;
	    name ~= super.mangle (t);
	}

	Table.instance.setCurrentSpace (Table.instance.globalNamespace ~ to!string (this._name.length) ~ this._name);
	
	auto proto = FrameTable.instance.existProto (name);
	    
	if (proto is null) {
	    
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    
	    proto = new FrameProto (name, un, Table.instance.retInfo.info, finalParams);
	    FrameTable.instance.insert (proto);

	    Table.instance.retInfo.currentBlock = "true";	    
	    auto block = this._function.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }

	    auto fr =  new FinalFrame (Table.instance.retInfo.info,
				       name, un,
				       finalParams, block);

	    proto.type = Table.instance.retInfo.info;
	    
	    FrameTable.instance.insert (fr);
	    
	    fr.file = this._function.ident.locus.file;
	    fr.dest = Table.instance.quitBlock ();
	    super.verifyReturn (this._function.ident,
				fr.type,
				Table.instance.retInfo);

	    
	    fr.last = Table.instance.quitFrame ();
	    
	    return proto;
	}
	Table.instance.quitBlock ();
	Table.instance.quitFrame ();
	return proto;	
    }

    /**
     Analyse sémantique de la frame.
     Params:
     params = Les informations de type à appliqué à la frame.
     Returns: le prototype de la frame analysé.
    */
    override FrameProto validate (ParamList params) {
	string un = Table.instance.namespace ~ to!string (this._name.length) ~ this._name;
	string name = Table.instance.namespace ~ to!string (this._name.length) ~ super.mangle (this._name);
	name = "_YN" ~ to!string (name.length) ~ name;
	Table.instance.enterFrame (name, this._function.params.length);
	Table.instance.enterBlock ();
	
	Array!Var finalParams;
	foreach (it; 0 .. this._function.params.length) {
	    if (cast(TypedVar)this._function.params [it] is null) {
		auto var = this._function.params [it].setType (params.params [it].info);   
		finalParams.insertBack (var.expression);
	    } else finalParams.insertBack (this._function.params [it].expression);
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    finalParams.back ().info.id = it + 1;
	    name ~= super.mangle (t);
	}
	
	Table.instance.setCurrentSpace (this._namespace ~ to!string (this._name.length) ~ this._name);
	
	auto proto = FrameTable.instance.existProto (name);
	    
	if (proto is null) {
	    
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    
	    proto = new FrameProto (name, un, Table.instance.retInfo.info, finalParams);
	    FrameTable.instance.insert (proto);

	    Table.instance.retInfo.currentBlock = "true";	    
	    auto block = this._function.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }

	    auto fr =  new FinalFrame (Table.instance.retInfo.info,
				       name, un,
				       finalParams, block);

	    proto.type = Table.instance.retInfo.info;
	    
	    FrameTable.instance.insertTemplate (fr);
	    
	    fr.file = this._function.ident.locus.file;
	    fr.dest = Table.instance.quitBlock ();
	    super.verifyReturn (this._function.ident,
				fr.type,
				Table.instance.retInfo);

	    
	    fr.last = Table.instance.quitFrame ();
	    
	    return proto;
	}
	Table.instance.quitBlock ();
	Table.instance.quitFrame ();
	return proto;
    }
    
}
