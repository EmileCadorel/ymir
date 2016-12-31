module ast.For;
import ast.Instruction;
import syntax.Word;
import ast.Expression, ast.Var;
import ast.Block;
import semantic.types.InfoType;
import semantic.pack.Table;
import utils.exception;
import semantic.pack.Symbol;
import semantic.types.UndefInfo;
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

    /// Les symboles à détruire à la fin de la boucle for.
    private Array!Symbol _dest;

    this (Word token, Word id, Array!Var var, Expression iter, Block block) {
	super (token);
	this._id = id;
	this._var = var;
	this._iter = iter;
	this._block = block;
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
     Returns: La liste des symboles à détruire
     */
    ref Array!Symbol dest () {
	return this._dest;
    }

    /**
     Returns: le block de la boucle
     */
    Block block () {
	return this._block;
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
	}

	auto expr = this._iter.expression;
	auto type = expr.info.type.ApplyOp (aux);
	if (type is null) throw new UndefinedOp (this.token, expr.info);
	
	foreach (it ; aux) Table.instance.insert (it.info);
	
	
	if (!this._id.isEof ()) this._block.setIdent (this._id);
	
	Table.instance.retInfo.currentBlock = "for";
	auto bl = this._block.block;
	auto res = new For (this._token, this._id, aux, expr, bl);
	res._ret = type;
	res._dest = Table.instance.quitBlock ();
	return res;
    }
    
}
