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

class Impl : Declaration {

    private Array!Function _methods;

    private Word _who;
    
    private Word _what;

    this (Word who, Word what, Array!Function methods) {
	this._methods = methods;
	this._what = what;
	this._who = who;
    }

    override void declare () {
	Array!FunctionInfo meth, stat;
	auto sym = Table.instance.get (this._what.str);	
	if (sym is null) {
	    throw new ImplementUnknown (this._what, Table.instance.getAlike (this._what.str));
	} else if (auto str = cast (StructCstInfo) sym.type) {
	    auto trait = Table.instance.get (this._who.str);
	    declareMethods (meth, stat);
	    auto obj = new ObjectCstInfo (str);
	    obj.setStatic (stat);
	    obj.setMethods (meth);
	    sym.type = obj;
	} else
	    throw new ImplementNotStruct (this._what, sym);
    }

    private void declareMethods (ref Array!FunctionInfo meth, ref Array!FunctionInfo stat) {
	foreach (it ; this._methods) {
	    if (it.params.length >= 1 && it.params [0].token.str == Keys.SELF.descr) {
		meth.insertBack (declare (it));
	    } else {
		stat.insertBack (declare (it));
	    }
	}
    }

    private FunctionInfo declare (Function fun) {
	Frame fr = fun.verifyPure ();
	auto space = Table.instance.namespace ();
	auto retFun = new FunctionInfo (space, fun.ident.str);
	retFun.alone = true;
	retFun.set (fr);
	return retFun;
    }
    
}
