module semantic.pack.TemplateFrame;
import semantic.types.InfoType;
import ast.Function, semantic.pack.Table;
import ast.ParamList, semantic.pack.Frame;
import std.container, ast.Var, std.conv;
import semantic.pack.Table, semantic.pack.Symbol;
import semantic.types.UndefInfo, semantic.types.VoidInfo;
import semantic.pack.FrameTable, syntax.Word;
import semantic.pack.FrameProto;
import semantic.pack.FinalFrame;
import semantic.types.TupleInfo;
import std.stdio, std.array;
import semantic.types.FunctionInfo, semantic.types.StructInfo;
import ast.Expression;
import ast.FuncPtr;
import ast.ConstArray;
import semantic.types.RefInfo;
import semantic.pack.UnPureFrame;

/**
 Cette classe est une instance de frame template
 */
class TemplateFrame : Frame {

    /** Le nom de la frame */
    private string _name;

    private bool _changed = false;

    /**
     Les premiers paramètre templates;
     */
    private Array!InfoType _tempParams;
    
    /**
     Params:
     namespace = le contexte de la frame
     func = la fonction associé à la frame
     */
    this (string namespace, Function func) {
	super (namespace, func);
	this._name = func.ident.str;
    }

    private Var typeIt (ArrayVar name, InfoType type, Array!Var args, InfoType [] tmps) {
	ArrayVar ret = new ArrayVar (name.token, null);
	auto typed = typeIt (name.content, type.getTemplate (0), args, tmps);
	if (!typed)
	    return null;
	
	ret.content = typed;	
	foreach (it ; 0 .. args.length) {
	    if (name.token.str == args [it].token.str) {
		if (tmps [it] is null) {
		    tmps [it] = (type);
		    this._changed = true;
		}
		return new Type (name.token, type.clone ());
	    }	    
	}
	
	return ret;
    }

    private Expression typeIt (ConstArray name, InfoType type, Array!Var args, InfoType [] tmps) {
	if (name.params.length == 1) {
	    if (auto var = cast (Var) name.params [0]) {
		auto typed = typeIt (var, type.getTemplate (0), args, tmps);
		if (typed !is null)
		    return new ConstArray (name.token, make!(Array!Expression) (typed));
		else return null;
	    }	    
	}
	return name;
    }
    
       
    private Var typeIt (Var name, InfoType type, Array!Var args, InfoType [] tmps) {
	if (type is null) return null;
	if (auto arr = cast (ArrayVar) name) return typeIt (arr, type, args, tmps);
	else if (name.token.str == "ref" && !cast (RefInfo) type) {
	    if (name.templates.length != 1) return null;
	    auto typed = typeIt (name.templates [0], type, args, tmps);
	    if (!typed) return null;
	    return new Var (name.token, make!(Array!Expression) (typed));
	}
	
	Array!Expression params;
	foreach (it ; 0 .. name.templates.length) {
	    if (auto var = cast (Var) name.templates [it]) {
		auto typed = typeIt (var, type.getTemplate (it), args, tmps);
		if (!typed)
		    return null;
		params.insertBack (typed);		
	    } else if (auto var = cast (ConstArray) name.templates [it]) {
		auto typed = typeIt (var, type.getTemplate (it), args, tmps);
		if (!typed)
		    return null;
		params.insertBack (typed);
	    } else params.insertBack (name.templates [it]);
	}
	
	foreach (it ; 0 .. args.length) {
	    if (name.token.str == args [it].token.str) {
		if (tmps [it] is null) {
		    tmps [it] = (type);
		    this._changed = true;
		}
		return new Type (name.token, type.clone ());
	    }	    
	}
	
	return new Var (name.token, params);
    }

    private Expression typeIt (Expression elem, InfoType type, Array!Var args, InfoType [] tmps) {
	if (auto fn = cast (FuncPtr) elem)
	    return typeIt (fn, type, args, tmps);
	else if (auto var = cast (Var) elem)
	    return typeIt (var, type, args, tmps);
	else if (auto cst = cast (ConstArray) elem)
	    return typeIt (cst, type, args, tmps);
	return null;
    }
    
    private FuncPtr typeIt (FuncPtr name, InfoType type, Array!Var args, InfoType [] tmps) {
	if (type is null) return null;
	Array!Var params;
	foreach (it ; 0 .. name.params.length) {
	    auto typed = typeIt (name.params [it], type.getTemplate (it), args, tmps);
	    if (!typed)
		return null;
	    params.insertBack (typed);	   
	}

	auto typed = typeIt (name.type, type.getTemplate (name.params.length), args, tmps);
	if (!typed) return null;
	
	return new FuncPtr (name.token, params, typed, null);
    }    
    
    override ApplicationScore isApplicable (Word ident, Array!Var attrs, Array!InfoType args) {
	auto score = new ApplicationScore (ident);
	InfoType [] tmps;
	tmps.length = this._function.tmps.length;
	foreach (it ; 0 .. this._tempParams.length)
	    tmps [it] = this._tempParams [it];
	
	if (attrs.length == 0 && args.length == 0) {
	    return null;
	} else if (attrs.length == args.length) {
	    foreach (it ; 0 .. args.length) {
		InfoType info = null;
		auto param = attrs [it];
		if (auto tvar = cast (TypedVar) param) {
		    this._changed = false;
		    if (tvar.type) {
			auto tmp = typeIt (tvar.type, args [it], this._function.tmps, tmps);			
			if (tmp is null) return null;
			info = tmp.asType ().info.type.clone ();
		    } else {
			auto tmp = typeIt (tvar.expType, args [it], this._function.tmps, tmps);
			if (tmp is null) return null;
			info = tmp.expression.info.type.clone ();
		    }
		    auto type = args [it].CompOp (info);
		    if (type && type.isSame (info)) {
			score.score += this._changed ? CHANGE : SAME;
			score.treat.insertBack (type);
		    } else if (type !is null) {
			score.score += AFF;
			score.treat.insertBack (type);
		    } else return null;		     
		} else {
		    if (cast (FunctionInfo) args [it] || cast (StructCstInfo) args [it])
			return null;
		    score.score += CHANGE;
		    score.treat.insertBack (args [it].clone ());
		}
	    }
	    
	    foreach (it; tmps) {
		if (it is null) return null;
	    }
	    score.tmps = tmps.array ();
	    return score;
	}
	return null;
    }
    
    override ApplicationScore isApplicable (ParamList params) {	
	return this.isApplicable (this._function.ident, this._function.params, params.paramTypes);
    }

    override ApplicationScore isApplicable (Array!InfoType params) {
	return this.isApplicable (this._function.ident, this._function.params, params);
    }
    
    override FrameProto validate (Array!InfoType params) {
	return null;
    }

    override FrameProto validate (ParamList params) {
	return null;
    }

    override FrameProto validate (ApplicationScore score, Array!InfoType params) {
	string name = Table.instance.globalNamespace ~ to!string (this._name.length) ~ this._name;
	name = "_YN" ~ to!string (name.length) ~ name;
	
	Table.instance.enterFrame (name, this._function.params.length);
	Table.instance.enterBlock ();
	
	Array!Expression types;	
	foreach (it ; this._tempParams) 
	    types.insertBack (new Type (Word.eof, it));		

	if (this._tempParams.length != this._function.tmps.length)
	    foreach (it ; score.tmps)
		types.insertBack (new Type (Word.eof, it.cloneForParam ()));

	auto func = this._function.templateReplace (this._function.tmps, types);
	this._function.print ();
	func.print ();
	
	Array!Var finalParams;
	foreach (it; 0 .. func.params.length) {
	    if (cast(TypedVar)func.params [it] is null) {
		auto var = func.params [it].setType (params [it]);   
		finalParams.insertBack (var.expression);
	    } else {
		finalParams.insertBack (func.params [it].expression);
	    }
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    finalParams.back ().info.id = it + 1;
	    name ~= super.mangle (t);
	}
	

	Table.instance.setCurrentSpace (Table.instance.globalNamespace ~ to!string (this._name.length) ~ this._name);	
	auto proto = FrameTable.instance.existProto (name);
	    
	if (proto is null) {
	    
	    if (func.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = func.type.asType ().info;
	    }
	    
	    proto = new FrameProto (name, Table.instance.retInfo.info, finalParams);
	    FrameTable.instance.insert (proto);

	    Table.instance.retInfo.currentBlock = "true";	    
	    auto block = func.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }
	    
	    auto fr =  new FinalFrame (Table.instance.retInfo.info,
				       name,
				       finalParams, block);

	    proto.type = Table.instance.retInfo.info;
	    
	    FrameTable.instance.insert (fr);
	    
	    fr.file = func.ident.locus.file;
	    fr.dest = Table.instance.quitBlock ();
	    super.verifyReturn (func.ident,
				fr.type,
				Table.instance.retInfo);

	    
	    fr.last = Table.instance.quitFrame ();


	    foreach (it ; func.tmps) {
		InfoType.removeAlias (it.token.str);
	    }
	    return proto;
	}
	
	Table.instance.quitBlock ();
	Table.instance.quitFrame ();
	return proto;	
    }


    override Frame TempOp (Array!Expression params) {
	if (params.length > this._function.tmps.length)
	    return null;

	InfoType [] totals;
	Array!InfoType finals;
	totals.length = this._function.tmps.length;
	
	foreach (it ; 0 .. params.length) {
	    auto tmp = typeIt (this._function.tmps [it], params [it].info.type, this._function.tmps, totals);
	    if (tmp is null) return null;
	    finals.insertBack (tmp.asType ().info.type.clone ());
	}

	if (finals.length == params.length) {	    
	    auto func = this._function.templateReplace (this._function.tmps, params);
	    return new UnPureFrame (this._namespace, func);
	} else {
	    auto aux = new TemplateFrame (this._namespace, this._function);
	    aux._tempParams = finals;
	    return aux;
	}	
    }
    
}