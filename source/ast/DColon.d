module ast.DColon;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;
import std.string;
import ast.Par, ast.Instruction;


/++
 Classe généré par la syntaxe 
 Example:
 -------
 expression '::' Identifiant.
 -------
 +/
class DColon : Expression {

    /// l'élément gauche de l'expression
    private Expression _left;

    /// L'élement de droite de l'expression
    private Expression _right;
    
    this (Word word, Expression left, Expression right) {
	super (word);
	this._left = left;
	this._right = right;
	this._left.inside = this;
	this._right.inside = this;
    }

    override Expression expression () {
	auto aux = new DColon (this._token, this._left.expression, this._right);

	if (cast (UndefInfo) aux._left.info.type) throw new UninitVar (aux._left.token);
	if (!cast (Var) aux._right) throw new UseAsVar (aux._right.token, aux._right.expression.info);
	auto var = cast (Var) aux._right;
	auto type = aux._left.info.type.DColonOp (var);
	if (type is null) {
	    throw new UndefinedAttribute (this._token, aux._left.info, var);
	}
	aux.info = new Symbol (aux._token, type);
	return aux;
    }

    override Expression templateExpReplace (Expression [string] values) {
	return new DColon (this._token, this._left.templateExpReplace (values),
			   this._right.templateExpReplace (values));
    }
    
    override Expression clone () {
	return new DColon (this._token, this._left.clone, this._right.clone ());
    }

    override string prettyPrint () {
	import std.format;
	return format ("%s::%s", this._left.prettyPrint, this._right.prettyPrint);
    }
    
}


