module ymir.ast.Global;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

class Global : Declaration {

    private Word _ident;
    
    private Expression _expr;

    private Expression _type;

    private InfoType _infoType;
    
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

	    this._infoType = sym.type;
	    sym.isStatic = true;
	    Table.instance.insert (sym);
	    Table.instance.addStaticInit (new Binary (op, new Var (this._ident), expr).expression);
	} else {
	    Expression type;
	    if (auto var = cast (Var) this._type) type = var.asType ();
	    else type = this._type.expression ();
	    
	    auto sym = new Symbol (this._ident, type.info.type.clone, false);
	    this._infoType = sym.type;
	    sym.isStatic = true;
	    Table.instance.insert (sym);
	}
	Table.instance.addGlobal (this);
    }

    InfoType type () {
	return this._infoType;
    }

    string name () {
	return this._ident.str;
    }
    
    override void declareAsExtern (Module mod) {}

    override Declaration templateReplace (Expression [string]) {
	assert (false, "Rien a faire la");
    }
   
}
