module ast.Is;
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
 'is' '(' exp ':' type ')'
 --------
*/
class Is : Expression {

    /// Le paramètre gauche
    private Expression _left;

    /// Le type à droite
    private Expression _type;

    this (Word begin, Expression expr, Expression type) {
	super (begin);
	this._left = expr;
	this._type = type;
    }
   
    /**
     Vérification sémantique
     Pour être juste le type doit éxister et l'élément tester doit être typé
     Throw: UseAsType, UninitVar
     */
    override Expression expression () {
	auto aux = new Is (this._token, this._left.expression, this._type.expression);

	if (!(cast (Type) aux._type)) throw new UseAsType (aux._type.token);
	if (cast (UndefInfo) aux._left) throw new UninitVar (aux._left.token);

	auto res = aux._left.info.type.isSame (aux._type.info.type);
	auto type = new BoolInfo ();
	aux._info = new Symbol (this._token, type, true);
	if (!res) 
	    aux._info.value = new BoolValue (false);
	else aux._info.value = new BoolValue (true);
	return aux;
    }

    /**
     Remplace les templates par les expressions associés
     */
    override Expression templateExpReplace (Array!Expression names, Array!Expression values) {
	auto left = this._left.templateExpReplace (names, values);
	auto right = this._type.templateExpReplace (names, values);
	return new Is (this._token, left, right);
    }

    /**
     */
    override Expression clone () {
	return new Is (this._token, this._left.clone (), this._type.clone ());
    }
    
}
