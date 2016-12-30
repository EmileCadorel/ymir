module ast.Expression;
import ast.Instruction;
import syntax.Word, semantic.pack.Symbol;

/**
 Ancêtre des expressions de l'arbre de syntaxe.
 */
class Expression : Instruction {

    /// L'information de l'expression
    protected Symbol _info;
    
    this (Word word) {
	super (word);
    }

    /**
     Returns les informations de l'expression
     */
    ref Symbol info () {
	return this._info;
    }

    /**
     Applique l'analyse sémantique de l'instruction
     */
    override final Instruction instruction () {
	return this.expression ();
    }

    /**
     Fonction à surcharger pour l'analyse sémantique.
     */
    Expression expression () {
	assert (false, "TODO");	
    }

    /**
     Fonction à surcharger pour l'affichage
     */
    void printSimple () {}

    /**
     Fonction à surcharger pour l'affichage
    */
    override void print (int nb = 0) {}
    
}

