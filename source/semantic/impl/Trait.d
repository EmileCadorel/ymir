module semantic.impl.Trait;

import semantic.types.StructInfo;
import ast.Function;
import std.container;
import semantic.types.InfoType;
import semantic.types.FunctionInfo;
import ast.Var, trait = ast.Trait;
import utils.Singleton;
import semantic.impl.Implementer;

alias TraitTable = TraitTableS.instance;

class TraitTableS {

    Array!TraitObj _traits;
    
    TraitObj exists (Namespace space, string name) {
	foreach (it ; this._traits) {
	    if (name == it.name && space.isSubOf (it.space)) {
		return it;
	    }
	}
	return null;
    }
    
    void insert (TraitObj t) {
	this._traits.insertBack (t);
    }
    
    mixin Singleton;
}


/++
 + Class Ancêtre des implémentations de structure.
 + Example:
 + ---------
 + trait Object {
 +      def toString () : string;
 + }
 + ---------
 +
+/
class TraitObj {

    private Word _locus;

    /++ La liste des prototypes de l'interface +/
    private Array!(trait.TraitProto) _prototypes;

    /++ L'emplacement de l'interface +/
    private Namespace _space;

    /++ Le nom de l'interface +/
    private string _name;

    this (Word locus, Namespace space, Array!(trait.TraitProto) meth) {
	this._locus = locus;
	this._name = locus.str;
	this._space = space;
	this._prototypes = meth;
    }                

    Word locus () {
	return this._locus;
    }

    Namespace space () {
	return this._space;
    }

    string name () {
	return this._name;
    }
    
}
