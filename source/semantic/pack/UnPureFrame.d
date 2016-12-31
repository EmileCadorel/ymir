module semantic.pack.UnPureFrame;
import ast.Function, semantic.types.InfoType;
import ast.ParamList, semantic.pack.Frame;
import std.container, ast.Var, std.conv;
import semantic.pack.Table, semantic.pack.Symbol;
import semantic.types.UndefInfo, semantic.types.VoidInfo;
import semantic.pack.FrameTable, syntax.Word;

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

    /**
     Analyse sémantique de la frame.
     Params:
     params = Les informations de type à appliqué à la frame.
     Returns: le prototype de la frame analysé.
     */
    override FrameProto validate (Array!InfoType params) {
	string name = this._namespace ~ to!string (this._name.length) ~ this._name;
	name = "_YN" ~ to!string (name.length) ~ name;
	
	Table.instance.enterFrame (name, this._function.params.length);
	Table.instance.enterBlock ();
	
	Array!Var finalParams;
	foreach (it; 0 .. this._function.params.length) {
	    if (cast(TypedVar)this._function.params [it] is null) {
		auto var = this._function.params [it].setType (params [it]);   
		finalParams.insertBack (var.expression);
	    } else finalParams.insertBack (this._function.params [it].expression);
	    auto t = finalParams.back ().info.type.typeString ();
	    finalParams.back ().info.id = it + 1;
	    name ~= super.mangle (t) ~ to!string (to!short (' '));
	}

	Table.instance.setCurrentSpace (this._namespace ~ to!string (this._name.length) ~ this._name);
	
	auto proto = FrameTable.instance.existProto (name);
	    
	if (proto is null) {
	    
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    
	    proto = new FrameProto (name, Table.instance.retInfo.info, finalParams);
	    FrameTable.instance.insert (proto);

	    Table.instance.retInfo.currentBlock = "true";	    
	    auto block = this._function.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }

	    auto fr =  new FinalFrame (Table.instance.retInfo.info,
				       name,
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
	string name = this._namespace ~ to!string (this._name.length) ~ this._name;
	name = "_YN" ~ to!string (name.length) ~ name;
	Table.instance.enterFrame (name, this._function.params.length);
	Table.instance.enterBlock ();
	
	Array!Var finalParams;
	foreach (it; 0 .. this._function.params.length) {
	    if (cast(TypedVar)this._function.params [it] is null) {
		auto var = this._function.params [it].setType (params.params [it].info);   
		finalParams.insertBack (var.expression);
	    } else finalParams.insertBack (this._function.params [it].expression);
	    auto t = finalParams.back ().info.type.typeString ();
	    finalParams.back ().info.id = it + 1;
	    name ~= super.mangle (t) ~ to!string (to!short (' '));
	}
	
	Table.instance.setCurrentSpace (this._namespace ~ to!string (this._name.length) ~ this._name);
	
	auto proto = FrameTable.instance.existProto (name);
	    
	if (proto is null) {
	    
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    
	    proto = new FrameProto (name, Table.instance.retInfo.info, finalParams);
	    FrameTable.instance.insert (proto);

	    Table.instance.retInfo.currentBlock = "true";	    
	    auto block = this._function.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }

	    auto fr =  new FinalFrame (Table.instance.retInfo.info,
				       name,
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
    
}
