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
    
    /** Le protocole créé à la sémantique lorsque la frame est pure et extern */
    private FrameProto _fr;
    
    /**
     Params:
     namespace = le contexte de la frame
     func = la fonction associé à la frame
     */
    this (Namespace namespace, Function func) {
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

	auto globSpace = Table.instance.namespace;
	Table.instance.setCurrentSpace (this._namespace, this._function.name);
	scope (exit) Table.instance.resetCurrentSpace (globSpace);
	
	if (attrs.length == 0 && args.length == 0) {
	    return null;
	} else if (attrs.length == args.length) {
	    foreach (it ; 0 .. args.length) {
		InfoType info = null;
		auto param = attrs [it];
		if (auto tvar = cast (TypedVar) param) {
		    this._changed = false;
		    TemplateSolution res = TemplateSolver.solve (this._function.tmps, tvar, args [it]);		    
		    if (!res.valid || !TemplateSolver.merge (score.score, tmps, res)) return null;
		    
		    info = res.type;
		    if (tvar.deco == Keys.REF && !cast (RefInfo) info) info = new RefInfo (info);		    
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
		    if (var.deco == Keys.REF && !cast (RefInfo) args[it]) {
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
		
	Table.instance.enterFrame (this._namespace, this._name, this._function.params.length, this._isInternal);
	Table.instance.enterBlock ();
       
	auto func = this._function.templateReplace (score.tmps);
	
	Array!Var finalParams = Frame.computeParams (func.params, params);

	Symbol ret = func.type !is null ? func.type.asType ().info : null;
	auto proto = Frame.validate (this._function.ident, this._namespace, Table.instance.globalNamespace, ret, finalParams, func.block, make!(Array!Expression) (score.tmps.values));
	return proto;
    }

    private string computeTempName (string name) {
	string un = this._name;	    
	Table.instance.pacifyMode ();
	un ~= "(";
	foreach (it ; func.tmps) {
	    if (auto _val = it.expression ().info.value) un ~= _val.toString;		    
	    else un ~= it.info.typeString;
	    
	    if (it !is func.tmps [$ - 1]) un ~= ",";
	    else un ~= ")";		
	}	
	Table.instance.unpacifyMode ();
	return un;
    }
    
    private FrameProto validateExtern () {
	if (!this._fr) {
	    string un = computeTempName (this._name);
	    
	    auto func = this._function;
	
	    Table.instance.enterFrame (this._namespace, un, this._function.params.length, this._isInternal);
	    Table.instance.enterBlock ();
	    Table.instance.setCurrentSpace (this._namespace, un);
			
	    Array!Var finalParams = Frame.computeParams (func.params);	
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (Word.eof(), new VoidInfo ());	    
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    this._fr = new FrameProto (un, this._namespace, Table.instance.retInfo.info, finalParams, make!(Array!Expression));
	    Table.instance.quitFrame ();
	}
	return this._fr;
    }
    

    override FrameProto validate () {
	if (this._isExtern) return validateExtern ();
	string un = computeTempName (this._name);
	auto name = Word (this._function.ident.locus, un, false);
	Table.instance.enterFrame (this._namespace, un, this._function.params.length, this._isInternal);
	Table.instance.enterBlock ();
		
	Array!Var finalParams = Frame.computeParams (func.params);
	auto ret = this._function.type ? this._function.type.asType ().info : null;	
	return Frame.validate (name, this._namespace, this._namespace, ret, finalParams, this._function.block, make!(Array!Expression));		
    }

    override Frame TempOp (Array!Expression params) {
    	import semantic.value.all;
    	this._currentScore = 0;
    	if (params.length > this._function.tmps.length)
    	    return null;

	auto globSpace = Table.instance.namespace;
	Table.instance.setCurrentSpace (this._namespace, this._function.name);
	scope (exit) Table.instance.resetCurrentSpace (globSpace);
	
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

	    
    	    ret.currentScore = this._currentScore + cast (int) res.score;
    	    return ret;
    	} else {
    	    func.tmps = TemplateSolver.unSolved (this._function.tmps, res);
    	    auto aux = new TemplateFrame (this._namespace, func);
    	    aux._currentScore = this._currentScore + cast (int) res.score;
    	    aux._isPure = this._isPure;
    	    aux._isExtern = this._isExtern;
    	    return aux;
    	}	
    }
    
}
