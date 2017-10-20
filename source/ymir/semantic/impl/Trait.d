module ymir.semantic.impl.Trait;
import ymir.semantic._;
import ymir.ast._;
import ymir.utils._;
import ymir.syntax._;

import std.container;
import trait = ymir.ast.Trait;


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
class TraitObj : InfoType {

    private Word _locus;

    /++ La liste des prototypes de l'interface +/
    private Array!(trait.TraitProto) _prototypes;

    /++ L'emplacement de l'interface +/
    private Namespace _space;

    /++ Le nom de l'interface +/
    private string _name;

    this (Word locus, Namespace space, Array!(trait.TraitProto) meth) {
	super (true);
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
    
    override bool isSame (InfoType) {
	return false;
    }

    override InfoType clone () {
	return this;
    }

    override InfoType cloneForParam () {
	return this;
    }

    override string innerTypeString () {
	return "";
    }
    
    override string simpleTypeString () {
	import std.format;
	return format ("%d%s%s", this._name.length, "IM", this._name);
    }

    
}
