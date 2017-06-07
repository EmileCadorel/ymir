module ast.Global;
import ast.Declaration;
import ast.all;
import syntax.Word;
import syntax.Tokens;
import semantic.pack.Table;
import semantic.pack.Symbol;
import utils.exception;

class Global : Declaration {

    private Word _ident;
    
    private Expression _expr;

    private Expression _type;
    
    this (Word ident, Expression expr, Expression type = null) {
	this._ident = ident;
	this._expr = expr;
	this._type = type;
    }

    override void declare () {
	auto info = Table.instance.get (this._ident.str);
	if (info !is null)
	    throw new ShadowingVar (this._ident, info.sym);
	auto op = Word (this._ident.locus, Tokens.EQUAL.descr, true);
	
	if (this._type is null) {
	    auto expr = this._expr.expression ();
	    if (cast (Type) expr) throw new UseAsVar (expr.token, expr.info);
	    
	    auto sym = new Symbol (this._ident, expr.info.type.cloneForParam (), false);
	    sym.isStatic = true;
	    Table.instance.insert (sym);
	    Table.instance.addStaticInit (new Binary (op, new Var (this._ident), expr).expression);
	} else {
	    Expression type;
	    if (auto var = cast (Var) this._type) type = var.asType ();
	    else type = this._type.expression ();
	    
	    auto sym = new Symbol (this._ident, type.info.type.clone, false);
	    sym.isStatic = true;
	    Table.instance.insert (sym);
	}
    }

    
    override void declareAsExtern (Module mod) {}

    override Declaration templateReplace (Expression [string]) {
	assert (false, "Rien a faire la");
    }
   
}
