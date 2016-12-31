module ast.Instruction;
import syntax.Word, ast.Block;

/**
 Ancêtre des Instructions de l'arbre de syntaxe.
 */
class Instruction {

    /// L'idenfiant de l'expression
    protected Word _token;

    /// Le block qui contient l'instruction
    protected Block _block;
    
    this (Word word) {
	this._token = word;
    }

    /**
     Returns: l'identifiant
     */
    Word token () {
	return this._token;
    }

    /**
     Returns: le block qui contient l'instruction
     */
    Block father () {
	return this._block;
    }

    /**
     Params:
     father = le block qui contient l'instruction
     */
    void father (Block father) {
	this._block = father;
    }

    /**
     Fonction à surcharger pour l'analyse sémantique.
     Throws: Assert
    */
    Instruction instruction () {
	assert (false, "TODO");
    }

    /**
     Fonctions à surcharger pour l'affichage
     */
    void print (int nb = 0) {}
    
}
