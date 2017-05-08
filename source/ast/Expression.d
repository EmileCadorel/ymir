module ast.Expression;
import ast.Instruction;
import syntax.Word, semantic.pack.Symbol;
import std.container;
import ast.Var;
import semantic.pack.Table;

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

    override Instruction templateReplace (Array!Expression names, Array!Expression values) {
	return this.templateExpReplace (names, values);
    }
    
    /**
     Remplace les templates par les expressions associés
     */
    Expression templateExpReplace (Array!Expression names, Array!Expression values) {
	assert (false, "TODO");
    }

    Expression clone () {
	return this;
    }

    /**
     Supprime tous les symboles de l'expression de la poubelle.
     */
    void removeGarbage () {
	if (this._info) {
	    Table.instance.removeGarbage (this._info);
	}
    }

    /**
     */
    void garbage () {
	if (this._info && this._info.isDestructible)
	    Table.instance.garbage (this._info);
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

