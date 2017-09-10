module ymir.semantic.impl.Implementer;
import ymir.semantic._;
import ymir.ast._;

import std.container;


/++
 + Classe résponsable d'une implémentation de structure.
 + Example:
 + -------
 +
 + struct Test {
 +    a : int
 + }
 +
 + impl Object for Test {
 +    def new () { return Test (10); }
 +    def foo (self) { println (self.to!string); }
 + }
 +
 + // ...
 + 
 + let a = Test::new ();
 + -------
+/
class Implementer : InfoType {

    /++ La structure que l'on implémente +/
    private StructCstInfo _str;

    /++ La liste des méthodes implémentées dans l'implémenteur +/
    private Array!FunctionInfo _methods;

    /++ La liste de fonction statique +/
    private Array!FunctionInfo _statics;
    
    this (StructCstInfo str, Array!FunctionInfo statics, Array!FunctionInfo funcs)  {
	this._str = str;
	this._methods = funcs;
	this._statics = statics;

	foreach (it ; this._methods)
	    it.alone = true;

	foreach (it ; this._statics)
	    it.alone = true;	
    }
    
    
}

