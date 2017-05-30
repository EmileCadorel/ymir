module semantic.impl.Implementer;
import semantic.types.StructInfo;
import ast.Function;
import std.container;
import semantic.types.InfoType;
import semantic.types.FunctionInfo;
import ast.Var;

/++
 + Classe résponsable d'une implémentation de structure.
 + Example:
 + -------
 +
 + struct Test {
 +    a : int
 + }
 +
 + impl Test {
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

    /++
     Surcharge de l'operateur '::'
     +/
    override InfoType DColonOp (Var var) {
	foreach (it ; this._statics) {
	    if (var.token.str == it.name) {
		return it;
	    }
	}
	return null;
    }        
    
}

