module ast.Par;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio, std.string;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;

class Par : Expression {

    private Word _end;
    private ParamList _params;
    private Expression _left;
    private ApplicationScore _score;
    
    this (Word word, Word end, Expression left, ParamList params) {
	super (word);
	this._end = end;
	this._params = params;
	this._left = left;
    }

    this (Word word, Word end) {
	super (word);
	this._end = end;
    }
    
    override Expression expression () {
	auto aux = new Par (this._token, this._end);
	aux._params = (cast(ParamList)this._params.expression ());
	aux._left = this._left.expression ();
	if (cast (Type) aux._left !is null) throw new UndefinedVar (aux._left.token);
	else if (cast(UndefInfo) aux._left.info !is null) throw new UninitVar (aux._left.token);
	auto type = aux._left.info.type.CallOp (aux._left.token, aux._params);
	if (type is null) {
	    throw new UndefinedOp (this._token, this._end, aux._left.info, aux._params);
	}
	
	aux._score = type;
	aux._info = new Symbol (this._token, type.ret, true);
	if (cast (UndefInfo) type.ret) {
	    throw new TemplateInferType (aux._left.token, aux._score.token);
	}
	
	return aux;
    }
    
    ApplicationScore score () {
	return this._score;
    }

    Array!Expression params () {
	return this._params.params;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Par> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._left.print (nb + 4);
	this._params.print (nb + 4);	
    }

}
