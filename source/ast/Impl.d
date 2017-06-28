module ast.Impl;
import syntax.Word, utils.exception;
import ast.all;
import semantic.pack.Table, semantic.pack.Symbol;
import std.container, semantic.types.StructInfo;
import trait = semantic.impl.Trait;
import semantic.impl.ObjectInfo;
import semantic.types.FunctionInfo;
import ast.Function, syntax.Keys;
import semantic.pack.Frame;
import semantic.pack.FrameTable;

class Impl : Declaration {

    private Array!Function _methods;

    private Array!bool _herit;

    private Word _who;
    
    private Word _what;

    this (Word what, Array!Function methods) {
	this._methods = methods;
	this._what = what;
	this._who = Word.eof;
    }
    
    this (Word who, Word what, Array!Function methods, Array!bool herit) {
	this._methods = methods;
	this._what = what;
	this._who = who;
	this._herit = herit;
    }

    override void declare () {
	Array!FunctionInfo meth, stat;
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
	    
	    declareMethods (space, meth, stat);
	    auto obj = new ObjectCstInfo (this._what, str);
	    obj.setStatic (stat);
	    obj.setMethods (meth);
	    str.methods = meth;
	    sym.type = obj;
	    obj.setAncestor (ancestor);
	    FrameTable.instance.insert (obj);
	} else
	    throw new ImplementNotStruct (this._what, sym);
    }

    override void declareAsExtern (Module mod) {
	Array!FunctionInfo meth, stat;
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
	    
	    declareMethods (space, meth, stat);
	    auto obj = new ObjectCstInfo (this._what, str);
	    obj.setStatic (stat);
	    obj.setMethods (meth);
	    str.methods = meth;
	    sym.type = obj;
	    obj.setAncestor (ancestor);
	} else
	    throw new ImplementNotStruct (this._what, sym);
    }
    
    
    private void declareMethods (Namespace space, ref Array!FunctionInfo meth, ref Array!FunctionInfo stat) {
	foreach (it ; this._methods) {
	    if (it.params.length >= 1 && it.params [0].token.str == Keys.SELF.descr) {
		meth.insertBack (declareMeth (space, it));
	    } else {
		stat.insertBack (declareStat (space, it));
	    }
	}
    }

    private void declareMethodsAsExtern (Namespace space, ref Array!FunctionInfo meth, ref Array!FunctionInfo stat) {
	foreach (it ; this._methods) {
	    if (it.params.length >= 1 && it.params [0].token.str == Keys.SELF.descr) {
		meth.insertBack (declareMethAsExtern (space, it));
	    } else {
		stat.insertBack (declareStatAsExtern (space, it));
	    }
	}
    }
    
    private FunctionInfo declareMeth (Namespace space, Function fun) {
	import semantic.pack.PureFrame;
	auto name = Word (this._what.locus, this._what.str, false);
	fun.params [0] = new TypedVar (fun.params [0].token, new Var (name));
	auto fr = cast (PureFrame) fun.verifyPure (space);
	if (fr is null)
	    throw new ImplMethodNotPure (fun.ident);
	auto retFun = new FunctionInfo (space, fun.ident.str);
	retFun.alone = true;
	retFun.set (fr);
	return retFun;
    }

    private FunctionInfo declareStat (Namespace space, Function fun) {
	Frame fr = fun.verifyPure (space);
	auto retFun = new FunctionInfo (space, fun.ident.str);
	retFun.alone = true;
	retFun.set (fr);
	return retFun;
    }

    private FunctionInfo declareMethAsExtern (Namespace space, Function fun) {
	import semantic.pack.PureFrame;
	auto name = Word (this._what.locus, this._what.str, false);
	fun.params [0] = new TypedVar (fun.params [0].token, new Var (name));
	auto fr = cast (PureFrame) fun.verifyPureAsExtern (space);
	if (fr is null)
	    throw new ImplMethodNotPure (fun.ident);
	auto retFun = new FunctionInfo (space, fun.ident.str);
	retFun.alone = true;
	retFun.set (fr);
	return retFun;
    }

    private FunctionInfo declareStatAsExtern (Namespace space, Function fun) {
	Frame fr = fun.verifyPureAsExtern (space);
	auto retFun = new FunctionInfo (space, fun.ident.str);
	retFun.alone = true;
	retFun.set (fr);
	return retFun;
    }

    
}
