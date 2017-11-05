module ymir.ast.Constructor;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container, std.stdio, std.string;

/**
   Classe généré par la syntaxe : 
   Example : 
   ----
   'def' '(' 'self' (, var)* ')' block 
   ----
 */
class Constructor : Function {

    private Array!Var _params;
    
    this (Word ident, Array!Var params, Block block) {
	super (Word (ident.locus, ident.str ~ "__cst__", false),
	       make!(Array!Var) (new Var (this.ident)) ~ params,
	       make!(Array!Expression), null, block);
    }
    
}
