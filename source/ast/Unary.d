module ast.Unary;
import ast.Expression;
import ast.Var;
import syntax.Word, semantic.types.InfoType;
import semantic.types.UndefInfo, utils.exception;
import std.stdio, std.string, semantic.pack.Symbol;

class BefUnary : Expression {

    private Expression _elem;
    
    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
    }

    override Expression expression () {
	auto aux = new BefUnary (this._token, this._elem.expression);
	if (cast (Type) aux._elem !is null) throw new UndefinedVar (aux._elem.token);
	if (cast (UndefInfo) aux._elem.info.type !is null) throw new UninitVar (aux._elem.token);
	auto type = aux._elem.info.type.UnaryOp (this._token);
	if (type is null) {
	    throw new UndefinedOp (this._token, aux._elem.info);
	}
	
	aux._info = new Symbol (aux._token, type);
	return aux;
    }
    
    Expression elem () {
	return this._elem;
    }

    override void print (int nb = 0) {
	writefln ("%s<BefUnary> %s(%d, %d) %s",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	this._elem.print (nb + 4);    
    }

    
}

class AfUnary : Expression {

    private Expression _elem;

    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
    }
   
    override Expression expression () {
	auto aux = new BefUnary (this._token, this._elem.expression);
	if (cast (Type) aux._elem !is null) throw new UndefinedVar (aux._elem.token);
	if (cast (UndefInfo) aux._elem.info.type !is null) throw new UninitVar (aux._elem.token);
	auto type = aux._elem.info.type.UnaryOp (this._token);
	if (type is null) {
	    throw new UndefinedOp (this._token, aux._elem.info);
	}
	
	aux._info = new Symbol (aux._token, type);
	return aux;
    }

    override void print (int nb = 0) {
	writefln ("%s<AfUnary> %s(%d, %d) %s",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	this._elem.print (nb + 4);    
    }    
}
