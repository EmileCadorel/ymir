module ymir.semantic.pack.TemplateFrame;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;

import std.container, std.conv;
import std.stdio, std.array;


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

    static long CONST_SAME_TMP = 9;
    static long SAME_TMP = 10;
    static long CONST_AFF_TMP = 4;    
    static long AFF_TMP = 5;
    static long CONST_CHANGE_TMP = 6;    
    static long CHANGE_TMP = 7;
    
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
	if (attrs.length == 0)
	    return null;
	else if (auto tvar = cast (TypedVar) attrs [$ - 1]) {
	    Array!InfoType others = make!(Array!InfoType) (params [attrs.length - 1 .. $]);
	    
	    auto res = TemplateSolver.getVariadic (this._function.tmps, tvar.type, others);
	    if (!res.valid) return null;
	    else {
		foreach (ref expr ; res.elements) {
		    if (expr.info.isImmutable ()) expr = expr.info.value.toYmir (expr.info);
		}
		    
		auto func = this._function.templateReplace (res.elements);
		Frame tmps;
		if (!TemplateSolver.isSolved (this._function.tmps, res)) {
		    func.tmps = TemplateSolver.unSolved (this._function.tmps, res);
		    tmps = new TemplateFrame (this._namespace, func);
		} else {
		    tmps = new UnPureFrame (this._namespace, func);
		}

		tmps.isVariadic = true;
		auto types = make!(Array!InfoType) (params [0 .. attrs.length - 1]);
		types.insertBack (res.type);
		auto score = tmps.isApplicable (types);
		
		if (score) {
		    score.score += res.score;
		    score.toValidate = tmps;
		}
		return score;				
	    }
	} return null;
    }    
    
    private ApplicationScore isApplicableSimple (Word ident, Array!Var attrs, Array!InfoType args) {
	auto score = new ApplicationScore (ident);
	Expression [string] tmps;

	auto tScope = Table.instance.templateScope;
	auto globSpace = Table.instance.namespace;
	Table.instance.setCurrentSpace (this._namespace, this._function.name);
	Table.instance.templateScope = globSpace;
	scope (exit) {
	    Table.instance.resetCurrentSpace (globSpace);
	    Table.instance.templateScope = tScope;
	}
	
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
		    if (tvar.deco == Keys.CONST) info.isConst = true;
		    else info.isConst = false;
		    
		    auto type = args [it].CompOp (info);
		    if (type) type = type.ConstVerif (info);
		    else return null;
		    if (type && type.isSame (info)) {
			if (!args [it].isConst && info.isConst) score.score += this._changed ? CONST_CHANGE_TMP : CONST_SAME_TMP;
			else if (args [it].isConst && !info.isConst) score.score += this._changed ? CONST_CHANGE_TMP : CONST_SAME_TMP;
			else score.score += this._changed ? CHANGE_TMP : SAME_TMP;
			score.treat.insertBack (type);
		    } else if (type !is null) {
			if (!args [it].isConst && info.isConst) score.score += CONST_AFF_TMP;
			else if (args [it].isConst && !info.isConst) score.score += CONST_AFF_TMP;
			else score.score += AFF_TMP;
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
	    else {
		foreach (ref exp ; tmps) {
		    if (exp.info.isImmutable ()) {
			exp = exp.info.value.toYmir (exp.info);
		    }
		}
	    }
	    
	    if (this._function.test) {		
		auto valid = func.test.templateExpReplace (tmps) .expression ();
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
	auto proto = Frame.validate (this._function.ident, this._namespace, Table.instance.globalNamespace, ret, finalParams, func.block, make!(Array!Expression) (score.tmps.values), this._isVariadic);
	return proto;
    }

    private string computeTempName (string name) {
	string un = this._name;	    
	un ~= "(";
	foreach (it ; func.tmps) {
	    if (auto _val = it.expression ().info.value) un ~= _val.toString;		    
	    else un ~= it.info.typeString;
	    
	    if (it !is func.tmps [$ - 1]) un ~= ",";
	    else un ~= ")";		
	}	
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
    	this._currentScore = 0;
    	if (params.length > this._function.tmps.length)
    	    return null;

	auto globSpace = Table.instance.namespace;
	auto tScope = 	Table.instance.templateScope;
	Table.instance.setCurrentSpace (this._namespace, this._function.name);
	Table.instance.templateScope = globSpace;
	scope (exit) {
	    Table.instance.resetCurrentSpace (globSpace);
	    Table.instance.templateScope = tScope;
	}
	
    	InfoType [] totals;
    	Array!Expression finals;
    	Array!Expression vars;
    	totals.length = this._function.tmps.length;

	auto res = TemplateSolver.solve (this._function.tmps, params);

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
	
	foreach (name, ref expr ; res.elements) {
	    if (expr.info.isImmutable ()) expr = expr.info.value.toYmir (expr.info);
	}
	
    	auto func = this._function.templateReplace (res.elements);	
	
    	func.name = func.name ~ namespace;
    	import std.algorithm : any;
	
    	if (TemplateSolver.isSolved (this._function.tmps, res)) {	    
    	    if (func.test) {		
    		auto valid = func.test.expression ();
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
