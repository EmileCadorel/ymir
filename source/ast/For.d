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

class For : Instruction {

    private Word _id;
    private Array!Var _var;
    private Expression _iter;
    private Block _block;
    private InfoType _ret;
    
    this (Word token, Word id, Array!Var var, Expression iter, Block block) {
	super (token);
	this._id = id;
	this._var = var;
	this._iter = iter;
	this._block = block;
    }        

    Array!Var vars () {
	return this._var;
    }    

    Expression iter () {
	return this._iter;
    }
    
    InfoType ret () {
	return this._ret;
    }
    
    Block block () {
	return this._block;
    }
    
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
	Table.instance.quitBlock ();
	return res;
    }
    
}
