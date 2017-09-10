module ymir.ast.OfVar;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;
import ymir.utils._;


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

class VariadicVar : Var {

    this (Word ident) {
	super (ident);
    }

    override Var expression () {
	assert (false);
    }

    override Var templateExpReplace (Expression [string] values) {
	if (auto it = this._token.str in values) return null; 
	else return this;
    }
    
}

class VariadicSoluce : Expression {
    
    private InfoType [] _types;

    this (Word ident, InfoType [] types) {
	super (ident);
	this._types = types;
    }

    override Expression expression () {
	throw new UseAsExp (this._token);
    }

    InfoType [] types () {
	return this._types;
    }
    
    override Expression templateExpReplace (Expression [string] values) {
	assert (false);
    }
    
}
