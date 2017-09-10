module ymir.ast.Expression;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container;

/**
 Ancêtre des expressions de l'arbre de syntaxe.
 */
class Expression : Instruction {

    /// L'information de l'expression
    protected Symbol _info;

    /// L'instruction dont fait partie l'expression
    protected Instruction _inside;

    this (Word word) {
	super (word);
    }

    /**
     Returns: les informations de l'expression
     */
    ref Symbol info () {
	return this._info;
    }

    /**
     Applique l'analyse sémantique de l'instruction
     */
    override Instruction instruction () {
	return this.expression ();
    }

    /**
     Fonction à surcharger pour l'analyse sémantique.
     */
    Expression expression () {
	assert (false, "TODO");	
    }

    override Instruction templateReplace (Expression [string] values) {
	return this.templateExpReplace (values);
    }
    
    /**
     Remplace les templates par les expressions associés
     */
    Expression templateExpReplace (Expression [string] values) {
	assert (false, "TODO");
    }

    Expression clone () {
	return this;
    }

    /**
     Fonction à surcharger pour l'affichage
     */
    void printSimple () {}

    /**
     Fonction a surcharger pour la transformation en prettyPrint
     */
    string prettyPrint () {
	assert (false, "TODO " ~ typeid (this).toString ~ ".prettyPrint");
    }

    /**
     L'instruction dont l'expression fait partie
     */
    ref Instruction inside () {
	return this._inside;
    }

    /**
     Fonction à surcharger pour l'affichage
    */
    override void print (int nb = 0) {}
    
}

