module ast.TypeOf;
import ast.Expression;
import ast.Var;
import syntax.Word, utils.YmirException, utils.exception;
import semantic.value.BoolValue;
import semantic.types.BoolInfo;
import semantic.pack.Symbol;
import semantic.types.TupleInfo;
import semantic.types.UndefInfo;
import std.container;
import ast.ParamList;
import semantic.types.StructInfo;
import std.stdio;


/**
 Classe généré par la syntaxe
 Example:
 --------
 'typeof' '(' exp ')'
 --------
*/
class TypeOf : Expression {

    /// Le paramètre de l'expression
    private Expression _expr;

    this (Word begin, Expression expr) {
	super (begin);
	this._expr = expr;
    }

    /**
     Vérification sémantique
     Pour être juste l'expression doit être typé et pas un type
     Throw: UseAsVar, UninitVar
     */
    override Expression expression () {
	auto expr = this._expr.expression ();
	if (cast (Type) expr) throw new UseAsVar (expr.token, expr.info);
	else if (cast (UndefInfo) expr.info.type) throw new UninitVar (expr.token);

	auto res = new Type (this._token, expr.info.type);
	return res;
    }

    override Expression templateExpReplace (Array!Expression names, Array!Expression values) {
	auto left = this._expr.templateExpReplace (names, values);
	return new TypeOf (this._token, left);
    }

    override Expression clone () {
	return new TypeOf (this._token, this._expr.clone ());
    }

    override string prettyPrint () {
	import std.format;
	return format ("typeof (%s)", this._expr.prettyPrint ());
    }    

}
