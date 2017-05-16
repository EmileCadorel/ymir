module ast.OfVar;

import ast.Expression;
import ast.Var;
import syntax.Word;

class OfVar : Var {
    
    private Var _type;

    this (Word ident, Var type) {
	super (ident);
	this._type = type;
    }    

    override OfVar expression () {
	assert (false);
    }

    override Var templateExpReplace (Expression [string] values) {
	auto type = cast (Var) this._type.templateExpReplace (values);
	return new OfVar (this._token, type);
    }
    
    Var type () {
	return this._type;
    }
            
}