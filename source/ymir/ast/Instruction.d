module ymir.ast.Instruction;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container;


/**
 Ancêtre des Instructions de l'arbre de syntaxe.
 */
class Instruction {

    /// L'idenfiant de l'expression
    protected Word _token;

    /// Le block qui contient l'instruction
    protected Block _block;

    /// L'instruction doit être traité à la compilation ?
    protected bool _isStatic;
    
    this (Word word) {
	this._token = word;
    }

    /**
     Returns: l'identifiant
     */
    ref Word token () {
	return this._token;
    }

    /**
     Returns: L'instruction doit être traité à la compilation ?
     */
    bool isStatic () {
	return this._isStatic;
    }

    void isStatic (bool isStatic) {
	this._isStatic = isStatic;
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

    final void setFatherBlock (Block father) {
	this._block = father;
    }
    
    /**
     Fonction à surcharger pour l'analyse sémantique.
     Throws: Assert
    */
    Instruction instruction () {
	assert (false, "TODO");
    }

    Instruction templateReplace (Expression [string]) {
	assert (false, "TODO");
    }
    
    /**
     Fonctions à surcharger pour l'affichage
     */
    void print (int nb = 0) {}
    
}

class None : Instruction {
    this (Word tok) {
	super (tok);
    }
}
