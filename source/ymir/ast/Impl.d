module ymir.ast.Impl;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container;
import trait = ymir.semantic.impl.Trait;

class Impl : Declaration {

    private Array!Function _methods;

    private Array!Constructor _csts;
    
    private Array!bool _herit;

    private Word _who;
    
    private Word _what;

    this (Word what, Array!Function methods, Array!Constructor csts) {
	this._methods = methods;
	this._what = what;
	this._who = Word.eof;
	this._csts = csts;
    }
    
    this (Word who, Word what, Array!Function methods, Array!bool herit, Array!Constructor csts) {
	this._methods = methods;
	this._what = what;
	this._who = who;
	this._herit = herit;
	this._csts = csts;
    }

    override void declare () {
	Array!FunctionInfo stat; Array!MethodInfo meth;
	Array!ConstructorInfo csts;
	auto sym = Table.instance.local (this._what.str);
	auto ext = Table.instance.get (this._what.str);
	if (sym is null) {	    
	    if (ext !is null)
		throw new ImplementNotLocal (this._what, ext);
	    else
		throw new ImplementUnknown (this._what, Table.instance.getAlike (this._what.str));
	} else if (auto str = cast (StructCstInfo) sym.type) {
	    auto currSpace = Table.instance.namespace;
	    auto space = new Namespace (currSpace, this._what.str);
	    ObjectCstInfo ancestor;
	    if (!this._who.isEof) {
		auto trait = Table.instance.get (this._who.str);
		if (trait is null || !(cast (ObjectCstInfo) trait.type)) {
		    throw new InHeritError (this._who);
		} else ancestor = cast (ObjectCstInfo) trait.type;
	    }
	    
	    declareMethods (space, meth, stat, this._what.str);
	    declareConstructors (space, csts, this._what.str);
	    
	    auto obj = new ObjectCstInfo (this._what, str);
	    obj.setStatic (stat);
	    obj.setMethods (meth);
	    obj.setConstructs (csts);
	    
	    str.methods = meth;
	    str.csts = csts;
	    
	    sym.type = obj;
	    obj.setAncestor (ancestor);
	    FrameTable.instance.insert (obj);
	    obj.verify ();
	} else
	    throw new ImplementNotStruct (this._what, sym);
    }

    override void declareAsExtern (Module mod) {
	Array!FunctionInfo stat; Array!MethodInfo meth;
	Array!ConstructorInfo csts;
	auto sym = mod.get(this._what.str);
	if (sym is null) {	    
	    throw new ImplementUnknown (this._what, Table.instance.getAlike (this._what.str));
	} else if (auto str = cast (StructCstInfo) sym.type) {
	    auto currSpace = mod.space;
	    auto space = new Namespace (currSpace, this._what.str);
	    ObjectCstInfo ancestor;
	    if (!this._who.isEof) {
		auto trait = Table.instance.get (this._who.str);
		if (trait is null || !(cast (ObjectCstInfo) trait.type)) {
		    throw new InHeritError (this._who);
		} else ancestor = cast (ObjectCstInfo) trait.type;
	    }

	    declareMethods (space, meth, stat, this._what.str);
	    declareConstructors (space, csts, this._what.str);
		    
	    auto obj = new ObjectCstInfo (this._what, str);
	    obj.setStatic (stat);
	    obj.setMethods (meth);
	    obj.setConstructs (csts);
	    
	    str.methods = meth;
	    str.csts = csts;
	      
	    sym.type = obj;
	    obj.setAncestor (ancestor);
	    obj.verify ();
	} else
	    throw new ImplementNotStruct (this._what, sym);
    }


    private void declareConstructors (Namespace space, ref Array!ConstructorInfo csts, string imut) {
	ulong i = 0;
	foreach (it ; this._csts) {
	    csts.insertBack (declareConstruct (space, it, imut));
	}	
    }
    
    private void declareMethods (Namespace space, ref Array!MethodInfo meth, ref Array!FunctionInfo stat, string imut) {
	ulong i =  0;
	foreach (it ; this._methods) {
	    if (it.params.length >= 1 && it.params [0].token.str == Keys.SELF.descr) {
		auto m = declareMeth (space, it, imut);
		if (this._herit.length > i && this._herit [i] == true) m.isOverride = true;
		meth.insertBack (m);
	    } else {
		stat.insertBack (declareStat (space, it, imut));
	    }
	    i++;
	}
    }

    private void declareMethodsAsExtern (Namespace space, ref Array!MethodInfo meth, ref Array!FunctionInfo stat, string imut) {
	foreach (it ; this._methods) {
	    if (it.params.length >= 1 && it.params [0].token.str == Keys.SELF.descr) {
		meth.insertBack (declareMethAsExtern (space, it, imut));
	    } else {
		stat.insertBack (declareStatAsExtern (space, it, imut));
	    }
	}
    }

    private ConstructorInfo declareConstruct (Namespace space, Constructor cst, string imut) {
	auto name = Word (this._what.locus, this._what.str, false);
	cst.params [0] = new TypedVar (cst.params [0].token, new Var (name));
	auto fr = cst.verifyPure (space);
	if (fr is null)
	    throw new ImplMethodNotPure (cst.ident);
	fr.setImutSpace = imut;
	return new ConstructorInfo (space, cst.ident.str, fr);
    }
    
    private MethodInfo declareMeth (Namespace space, Function fun, string imut) {
	auto name = Word (this._what.locus, this._what.str, false);
	fun.params [0] = new TypedVar (fun.params [0].token, new Var (name));
	auto fr = fun.verifyPure (space);
	if (fr is null)
	    throw new ImplMethodNotPure (fun.ident);
	fr.setImutSpace = imut;
	return new MethodInfo (space, fun.ident.str, fr);
    }

    private FunctionInfo declareStat (Namespace space, Function fun, string imut) {
	Frame fr = fun.verifyPure (space);
	auto retFun = new FunctionInfo (space, fun.ident.str);
	retFun.alone = true;
	retFun.set (fr);
	fr.setImutSpace = imut;
	return retFun;
    }

    private MethodInfo declareMethAsExtern (Namespace space, Function fun, string imut) {
	auto name = Word (this._what.locus, this._what.str, false);
	fun.params [0] = new TypedVar (fun.params [0].token, new Var (name));
	auto fr = fun.verifyPureAsExtern (space);
	if (fr is null)
	    throw new ImplMethodNotPure (fun.ident);
	fr.setImutSpace = imut;
	return new MethodInfo (space, fun.ident.str, fr);
    }

    private FunctionInfo declareStatAsExtern (Namespace space, Function fun, string imut) {
	Frame fr = fun.verifyPureAsExtern (space);
	auto retFun = new FunctionInfo (space, fun.ident.str);
	retFun.alone = true;
	retFun.set (fr);
	fr.setImutSpace = imut;
	return retFun;
    }

    
}
