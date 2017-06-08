module ast.Impl;
import syntax.Word, utils.exception;
import ast.all;
import semantic.pack.Table, semantic.pack.Symbol;
import std.container;
import trait = semantic.impl.Trait;


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
	assert (false);
    }

}
