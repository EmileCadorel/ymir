module ymir.ast.For;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container;

/**
 Classe généré à la syntaxe par.
 Example:
 ---
 'for' (':' Identifiant)? '(' Identifiant* 'in' expression ')' 
 ---
 */
class For : Instruction {

    /// L'identifiant de boucle (peut-être eof)
    private Word _id;

    /// Les itérateurs
    private Array!Var _var;

    /// L'expression sur laquelle itérer
    private Expression _iter;

    /// Le block à executer à chaque itération
    private Block _block;

    /// L'information de la procédure à suivre (renseigné à la sémantique)
    private InfoType _ret;

    this (Word token, Word id, Array!Var var, Expression iter, Block block) {
	super (token);
	this._id = id;
	this._var = var;	
	this._iter = iter;
	this._iter.inside = this;
	this._block = block;
    }        


    /**
     Met à jour le père de la boucle
     Params: 
     father = le block qui contient l'instruction
     */
    override void father (Block father) {
	super._block = father;
	this._block.father = father;
    }
    
    /**
     Returns: la liste des itérateurs
     */
    Array!Var vars () {
	return this._var;
    }    

    /**
     Returns: l'expression à itérer
     */
    Expression iter () {
	return this._iter;
    }

    /**
     Returns: la procédure à suivre pour itérer
     */
    InfoType ret () {
	return this._ret;
    }

    /**
     Returns: le block de la boucle
     */
    Block block () {
	return this._block;
    }

    Word name () {
	return this._id;
    }
    
    /**
     Vérification sémantique.
     Pour être juste l'iterable doit avoir surcharger l'operateur (ApplyOp) avec les itérateur.
     Throws: ShadowingVar, UndefinedOp
     */
    override Instruction instruction () {
	Array!Var aux;
	Table.instance.enterBlock ();
	foreach (it ; this._var) {
	    aux.insertBack (new Var (it.token));
	    auto info = Table.instance.get (it.token.str);
	    if (info !is null) throw new ShadowingVar (it.token, info.sym);	    
	    aux.back.info = new Symbol (aux.back.token, new UndefInfo ());
	    aux.back.info.isConst = false;
	    aux.back.info.value = null;
	}

	auto expr = this._iter.expression;
	auto type = expr.info.type.ApplyOp (aux);
	if (type is null) throw new UndefinedOp (this.token, expr.info);	
	
	foreach (it ; aux) Table.instance.insert (it.info);	
	
	if (!this._id.isEof ()) this._block.setIdent (this._id);
	
	Table.instance.retInfo.currentBlock = "for";
	Table.instance.retInfo.changed = true;
	auto bl = this._block.blockWithoutEnter;
	auto res = new For (this._token, this._id, aux, expr, bl);
	res._ret = type;
	Table.instance.quitBlock ();
	return res;
    }


    override Instruction templateReplace (Expression [string] values) {
	Array!Var var;
	foreach (it ; this._var)
	    var.insertBack (cast (Var) it.templateExpReplace (values));

	auto iter = this._iter.templateExpReplace (values);
	auto block = this._block.templateReplace (values);
	return new For (this._token, this._id, var, iter, block);	
    }

    override void print (int nb = 0) {
	import std.stdio, std.string;
	writefln ("%s<While> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);

	foreach (it ; this._var)
	    it.print (nb + 4);
	this._iter.print (nb + 4);
	this._block.print (nb + 8);
    }
    
}
