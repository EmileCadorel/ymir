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
import semantic.pack.TemplateSolver;
import ast.Constante;
import ast.Binary;
import utils.exception;
import ast.OfVar;


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
	Expression [string] tmps;
	
	if (attrs.length == 0 && args.length == 0) {
	    return null;
	} else if (attrs.length == args.length) {
	    foreach (it ; 0 .. args.length) {
		InfoType info = null;
		auto param = attrs [it];
		if (auto tvar = cast (TypedVar) param) {
		    this._changed = false;
		    TemplateSolution res = TemplateSolver.solve (this._function.tmps, tvar, args [it]);		    
		    if (!res.valid || !TemplateSolver.merge (tmps, res.elements)) return null;
		    
		    info = res.type;
		    if (tvar.deco == Keys.REF) info = new RefInfo (info);		    
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
			score.treat.insertBack (args[it].cloneForParam ());
		    score.score += CHANGE;
		}
	    }
	    
	    if (!TemplateSolver.isSolved (this._function.tmps, tmps)) return null;
	    
	    if (this._function.test) {
		Table.instance.pacifyMode ();
		auto valid = func.test.templateExpReplace (tmps) .expression ();
		Table.instance.unpacifyMode ();
		if (!valid.info.isImmutable) throw new NotImmutable (valid.info);
		else if (!(cast (BoolValue)valid.info.value).isTrue) return null;	
	    }
	    
	    score.tmps = tmps;
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
       
	auto func = this._function.templateReplace (score.tmps);
	
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
	
	auto spaceName = super.mangle (this._name);
	Table.instance.setCurrentSpace (Table.instance.globalNamespace ~ to!string (spaceName.length) ~ spaceName);	
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
	auto res = TemplateSolver.solve (this._function.tmps, params);
    	Table.instance.unpacifyMode ();

	if (!res.valid)
	    return null;

    	string namespace = "(";

    	foreach (it ; params) {	    
    	    if (auto _val = it.info.value) {
    		namespace ~= (_val.toString);		
    	    } else
    		namespace ~= (it.info.type.simpleTypeString);
    	    if (it != params [$ - 1]) namespace ~= ",";
    	    else namespace ~= ")";
    	}
		
    	auto func = this._function.templateReplace (res.elements);	
	
    	func.name = func.name ~ namespace;
    	import std.algorithm : any;
	
    	if (TemplateSolver.isSolved (this._function.tmps, res)) {	    
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
    	    func.tmps = TemplateSolver.unSolved (this._function.tmps, res);
    	    auto aux = new TemplateFrame (this._namespace, func);
    	    aux._currentScore = this._currentScore;
    	    aux._isPure = this._isPure;
    	    aux._isExtern = this._isExtern;
    	    return aux;
    	}	
    }
    
}
