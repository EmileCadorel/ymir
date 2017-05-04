module semantic.pack.TemplateFrame;
import semantic.types.InfoType;
import ast.Function, semantic.pack.Table;
import ast.ParamList, semantic.pack.Frame;
import std.container, ast.Var, std.conv;
import semantic.pack.Table, semantic.pack.Symbol;
import semantic.types.UndefInfo, semantic.types.VoidInfo;
import semantic.pack.FrameTable, syntax.Word, syntax.Keys;
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
import semantic.pack.PureFrame;
import semantic.pack.ExternFrame;
import ast.Constante;
import ast.Binary;
import utils.exception;

/**
 Cette classe est une instance de frame template
 */
class TemplateFrame : Frame {

    /** Le nom de la frame */
    private string _name;

    private bool _changed = false;

    private bool _isPure = false;

    private bool _isExtern = false;
    
    /**
     Les premiers paramètre templates;
     */
    private Array!Expression _tempParams;

    /** Le protocole créé à la sémantique lorsque la frame est pure et extern */
    private FrameProto _fr;
    
    /**
     Params:
     namespace = le contexte de la frame
     func = la fonction associé à la frame
     */
    this (string namespace, Function func) {
	super (namespace, func);
	this._name = func.ident.str;
    }

    ref bool isPure () {
	return this._isPure;
    }

    ref bool isExtern () {
	return this._isExtern;
    }
    
    private Var typeIt (ArrayVar name, InfoType type, Array!Expression args, InfoType [] tmps) {
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
		this._currentScore += CHANGE;
		return new Type (name.token, type.clone ());
	    }	    
	}
	
	this._currentScore += CHANGE;
	return ret;
    }    
    
    private Var typeIt (ArrayVar name, Expression expr, Array!Expression args, InfoType [] tmps) {
	auto type = cast (Type) expr;
	if (type is null) return null;
	else return typeIt (name, type.info.type, args, tmps);
    }

    private Expression typeIt (ConstArray name, InfoType type, Array!Expression args, InfoType [] tmps) {
	if (name.params.length == 1) {
	    if (auto var = cast (Var) name.params [0]) {
		auto typed = typeIt (var, type.getTemplate (0), args, tmps);
		if (typed !is null)
		    return new ConstArray (name.token, make!(Array!Expression) (typed));
		else return null;
	    }	    
	}
	this._currentScore += CHANGE;
	return name;
    }

    private Expression typeIt (ConstArray name, Expression expr, Array!Expression args, InfoType [] tmps) {
	auto type = cast (Type) expr;
	if (type is null) return null;
	else return typeIt (name, type.info.type, args, tmps);
    }
           
    private TypedVar typeIt (TypedVar name, Expression expr, Array!Expression args, InfoType [] tmps) {
	auto type = name.type ().asType ();
	if (type.info.type.isSame (expr.info.type)) {
	    this._currentScore += CHANGE;
	    return name;
	}
	return null;
    }

    
    private Var typeIt (Var name, InfoType type, Array!Expression args, InfoType [] tmps) {
	if (type is null) return null;
	if (auto arr = cast (ArrayVar) name) return typeIt (arr, type, args, tmps);		
	
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
		this._currentScore += CHANGE;
		return new Type (name.token, tmps [it].clone ());
	    }	    
	}
	
	this._currentScore += CHANGE;
	return new Var (name.token, params);
    }

    
    private Var typeIt (Var name, Expression expr, Array!Expression args, InfoType [] tmps) {
	if (auto tvar = cast (TypedVar) name)
	    return typeIt (tvar, expr, args, tmps);
	auto type = cast (Type) expr;
	if (type is null) return null;
	else return typeIt (name, type.info.type, args, tmps);
    }

    
    private Expression typeIt (Expression elem, InfoType type, Array!Expression args, InfoType [] tmps) {
	if (auto fn = cast (FuncPtr) elem)
	    return typeIt (fn, type, args, tmps);
	else if (auto var = cast (Var) elem)
	    return typeIt (var, type, args, tmps);
	else if (auto cst = cast (ConstArray) elem)
	    return typeIt (cst, type, args, tmps);
	return null;
    }
    
    private Expression typeIt (Expression elem, Expression type, Array!Expression args, InfoType [] tmps) {
	if (auto fn = cast (FuncPtr) elem)
	    return typeIt (fn, type, args, tmps);
	else if (auto var = cast (Var) elem) 
	    return typeIt (var, type, args, tmps);
	else if (auto cst = cast (ConstArray) elem)
	    return typeIt (cst, type, args, tmps);
	else if (auto val = elem.expression ()) {
	    import semantic.value.BoolValue, syntax.Tokens;
	    if (!val.info.isImmutable) assert (false, typeid (elem).toString);
	    auto eq = cast (BoolValue) (val.info.value.BinaryOp (Tokens.DEQUAL, type.info.value));
	    auto eq2 = cast (BoolValue) (type.info.value.BinaryOp (Tokens.DEQUAL, val.info.value));
	    this._currentScore += SAME;
	    if (eq && eq.isTrue || eq2 && eq2.isTrue) return elem;
	}
	return null;
    }
    
    private FuncPtr typeIt (FuncPtr name, InfoType type, Array!Expression args, InfoType [] tmps) {
	Array!Var params;
	foreach (it ; 0 .. name.params.length) {
	    auto typed = typeIt (name.params [it], type.getTemplate (it), args, tmps);
	    if (!typed)
		return null;
	    params.insertBack (typed);	   
	}

	auto typed = typeIt (name.type, type.getTemplate (name.params.length), args, tmps);
	if (!typed) return null;

	this._currentScore += CHANGE;
	return new FuncPtr (name.token, params, typed, null);
    }

    private FuncPtr typeIt (FuncPtr name, Expression expr, Array!Expression args, InfoType [] tmps) {
	auto type = cast (Type) expr;
	if (type is null) return null;
	else return typeIt (name, type.info.type, args, tmps);
    }    

    override ApplicationScore isApplicable (Word ident, Array!Var attrs, Array!InfoType args) {
	if (args.length > this._function.params.length) return this.isApplicableVariadics (ident, attrs, args);
	else return this.isApplicableSimple (ident, attrs, args);
    }

    private ApplicationScore isApplicableVariadics (Word ident, Array!Var attrs, Array!InfoType params) {
	if (attrs.length == 0 || cast (TypedVar) attrs [$ - 1])
	    return null;
	else {
	    auto types = make!(Array!InfoType) (params [0 .. attrs.length]);
	    auto score = this.isApplicableSimple (ident, attrs, types);
	    if (score is null || score.score == 0) return score;
	    auto tuple = new TupleInfo ();
	    auto last = score.treat.back ();
	    auto tuple_types = make!(Array!InfoType) (params [attrs.length - 1 .. $]);
	    tuple.params = tuple_types;
	    score.treat.back () = tuple;
	    score.score += AFF - CHANGE;
	    return score;
	}
    }    
    
    private ApplicationScore isApplicableSimple (Word ident, Array!Var attrs, Array!InfoType args) {
	auto score = new ApplicationScore (ident);
	InfoType [] tmps;
	tmps.length = this._function.tmps.length;
	
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
			if (tvar.deco == Keys.REF) info = new RefInfo (tmp.asType ().info.type.clone ());
			else info = tmp.asType ().info.type.clone ();
		    } else {
			auto tmp = typeIt (tvar.expType, args [it], this._function.tmps, tmps);
			if (tmp is null) return null;
			if (tvar.deco == Keys.REF)  info = new RefInfo (tmp.expression.info.type.clone ());
			else info = tmp.expression.info.type.clone ();
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
		    auto var = cast (Var) attrs [it];
		    if (var.deco == Keys.REF) {
			auto type = args [it].CompOp (new RefInfo (args [it].clone ()));
			if (type is null) return null;
			score.treat.insertBack (type);
		    } else
			score.treat.insertBack (args[it].clone ());
		    score.score += CHANGE;
		}
	    }
	    
	    foreach (it; tmps) {
		if (it is null) return null;
	    }

	    if (this._function.test) {
		Table.instance.pacifyMode ();
		Array!Expression types;	
		foreach (it ; tmps)
		    types.insertBack (new Type (Word.eof, it.cloneForParam ()));
		
		auto valid = func.test.templateExpReplace (this._function.tmps, types) .expression ();
		Table.instance.unpacifyMode ();
		if (!valid.info.isImmutable) throw new NotImmutable (valid.info);
		else if (!(cast (BoolValue)valid.info.value).isTrue) return null;	
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
	if (this._isExtern) return validateExtern ();
	else if (this._isPure) return validate ();
	string un = Table.instance.globalNamespace ~ to!string (this._name.length) ~ this._name;
	string name = Table.instance.globalNamespace ~ to!string (this._name.length) ~ super.mangle (this._name);
	
	name = "_YN" ~ to!string (name.length) ~ name;
	
	Table.instance.enterFrame (name, this._function.params.length, this._isInternal);
	Table.instance.enterBlock ();
	
	Array!Expression types;	

	foreach (it ; score.tmps)
	    types.insertBack (new Type (Word.eof, it.cloneForParam ()));
	
	auto func = this._function.templateReplace (this._function.tmps, types);
	
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
	    
	    proto = new FrameProto (name, un, Table.instance.retInfo.info, finalParams);
	    FrameTable.instance.insert (proto);

	    Table.instance.retInfo.currentBlock = "true";	    
	    auto block = func.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }
	    
	    auto fr =  new FinalFrame (Table.instance.retInfo.info,
				       name, un,
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

    private FrameProto validateExtern () {
	if (!this._fr) {
	    string un = super.mangle (this._name);
	    string name = super.mangle (this._name); 
	    
	    Table.instance.pacifyMode ();
	    name ~= super.mangle("(");
	    un ~= "(";
	    foreach (it ; func.tmps) {
		if (auto _val = it.expression ().info.value) {
		    name ~= super.mangle (_val.toString);
		    un ~= _val.toString;		    
		} else {
		    name ~= super.mangle (it.info.typeString);
		    un ~= it.info.typeString;
		}			
		if (it !is func.tmps [$ - 1]) {
		    un ~= ",";
		    name ~= super.mangle (",");
		} else {
		    name ~= super.mangle (")") ;
		    un ~= ")";
		}
	    }
	
	    Table.instance.unpacifyMode ();

	    auto func = this._function;
	    auto simpleName = this._namespace ~ to!string(un.length) ~ name;
	    un = this._namespace ~ to!string (un.length) ~ un;
	    name = "_YN" ~ to!string (simpleName.length) ~ simpleName;
	
	    Table.instance.enterFrame (name, this._function.params.length, this._isInternal);
	    Table.instance.enterBlock ();
	    Table.instance.setCurrentSpace (simpleName);
			
	    Array!Var finalParams;
	    foreach (it; 0 .. func.params.length) {
		finalParams.insertBack (func.params [it].expression);	    
		auto t = finalParams.back ().info.type.simpleTypeString ();
		finalParams.back ().info.id = it + 1;
		name ~= super.mangle (t);
	    }
	
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (Word.eof(), new VoidInfo ());	    
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    this._fr = new FrameProto (name, un, Table.instance.retInfo.info, finalParams);
	    Table.instance.quitFrame ();
	}
	return this._fr;
    }
    

    override FrameProto validate () {
	if (this._isExtern) return validateExtern ();
	string un = super.mangle (this._name);
	string name = super.mangle (this._name); 
	       	       
	Table.instance.pacifyMode ();
	name ~= super.mangle("(");
	un ~= "(";
	foreach (it ; func.tmps) {
	    if (auto _val = it.expression ().info.value) {
		name ~= super.mangle (_val.toString);
		un ~= _val.toString;		    
	    } else {
		name ~= super.mangle (it.info.typeString);
		un ~= it.info.typeString;
	    }			
	    if (it !is func.tmps [$ - 1]) {
		un ~= ",";
		name ~= super.mangle (",");
	    } else {
		name ~= super.mangle (")") ;
		un ~= ")";
	    }
	}
	
	Table.instance.unpacifyMode ();

	auto func = this._function;
	auto simpleName = this._namespace ~ to!string(un.length) ~ name;
	un = this._namespace ~ to!string (un.length) ~ un;
	name = "_YN" ~ to!string (simpleName.length) ~ simpleName;
	
	Table.instance.enterFrame (name, this._function.params.length, this._isInternal);
	Table.instance.enterBlock ();
	Table.instance.setCurrentSpace (simpleName);
		
	Array!Var finalParams;
	foreach (it; 0 .. func.params.length) {
	    finalParams.insertBack (func.params [it].expression);	    
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    finalParams.back ().info.id = it + 1;
	    name ~= super.mangle (t);
	}
	
	auto proto = FrameTable.instance.existProto (name);
	
	if (proto is null) {	    
	    if (func.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = func.type.asType ().info;
	    }
	    
	    proto = new FrameProto (name, un, Table.instance.retInfo.info, finalParams);
	    FrameTable.instance.insert (proto);

	    Table.instance.retInfo.currentBlock = "true";	    
	    auto block = func.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }
	    
	    auto fr =  new FinalFrame (Table.instance.retInfo.info,
				       name, un,
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
	import semantic.value.all;
	this._currentScore = 0;
	if (params.length > this._function.tmps.length)
	    return null;

	InfoType [] totals;
	Array!Expression finals;
	Array!Expression vars;
	totals.length = this._function.tmps.length;

	Table.instance.pacifyMode ();
	foreach (it ; 0 .. params.length) {
	    Expression tmp;
	    if (params [it].info.isImmutable ||	cast (Type) params [it]) {
		tmp = typeIt (this._function.tmps [it], params [it], this._function.tmps, totals);	    		
	    } else if (auto tp = cast (StructCstInfo) params [it].info.type) {
		tmp = typeIt (this._function.tmps [it], tp, this._function.tmps, totals);
	    } else {
		Table.instance.unpacifyMode ();
		throw new NotImmutable (params [it].info);
	    }
	    if (tmp is null) {
		Table.instance.unpacifyMode ();
		return null;	    
	    }
	    finals.insertBack (tmp.expression ());
	    vars.insertBack (params [it]);
	}	

	Table.instance.unpacifyMode ();

	for (auto it = params.length ; it < this._function.tmps.length ; it++) {
	    if (cast (TypedVar) this._function.tmps [it])
		return null;
	}

	string namespace = "(";
	auto func = this._function.templateReplace (this._function.tmps, params);	
	foreach (it ; params) {	    
	    if (auto _val = it.info.value) {
		namespace ~= (_val.toString);		
	    } else
		namespace ~= (it.info.type.simpleTypeString);
	    if (it != params [$ - 1]) namespace ~= ",";
	    else namespace ~= ")";
	}
	
	func.name = func.name ~ namespace;
	
	if (this._function.tmps.length == params.length) {
	    if (func.test) {
		Table.instance.pacifyMode ();
		auto valid = func.test.expression ();
		Table.instance.unpacifyMode ();
		if (!valid.info.isImmutable) throw new NotImmutable (valid.info);
		else if (!(cast (BoolValue)valid.info.value).isTrue) return null;	
	    }
	    Frame ret;

	    if (!this._isPure) ret = new UnPureFrame (this._namespace, func);
	    else if (this._isExtern) ret = new ExternFrame (this._namespace, func);
	    else ret = new PureFrame (this._namespace, func);

	    
	    ret.currentScore = this._currentScore;
	    return ret;
	} else {
	    func.tmps = make!(Array!Expression) (this._function.tmps [params.length .. $]);
	    auto aux = new TemplateFrame (this._namespace, func);
	    aux._currentScore = this._currentScore;
	    aux._isPure = this._isPure;
	    aux._isExtern = this._isExtern;
	    return aux;
	}	
    }
    
}
