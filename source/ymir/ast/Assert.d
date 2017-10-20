module ymir.ast.Assert;
import ymir.ast._;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;

import std.stdio, std.string;
import std.container;


/**
 Class généré par la syntaxe:
 -----
 assert '(' expression (',' msg)? ')' ';'
 -----
 */
class Assert : Instruction {

    /// L'expression de test, pour savoir si on quitte le programme ou non
    private Expression _expr;

    /// Le message à afficher si le test est faux
    private Expression _msg;


    this (Word word, Expression test, Expression msg, bool isStatic = false) {
	super (word);
	this._expr = test;
	this._msg = msg;
	this._expr.inside = this;
	if (this._msg)
	    this._msg.inside = this;
	this._isStatic = isStatic;
    }

    /** Le test */
    Expression expr () {
	return this._expr;
    }

    /** Le message, peut être null */
    Expression msg () {
	return this._msg;
    }
    

    /**
     Vérification sémantique de l'instruction
     Pour être juste le test doit être de type bool et le msg de type string (ou null);
     Throws: IncompatibleTypes, 
     */
    override Instruction instruction () {
	auto expr = this._expr.expression;
	if (!expr.info.type.isSame (new BoolInfo (true)))       
	    throw new IncompatibleTypes (expr.info, new BoolInfo (true));

	Expression msg;
	if (this._msg) {
	    msg = this._msg.expression;
	    if (!msg.info.type.isSame (new StringInfo (true)))
		throw new IncompatibleTypes (msg.info, new StringInfo (true));	   
	}
	
	if (this._isStatic) {
	    if (msg && msg.info.value is null) 
		throw new NotImmutable (msg.info);
	    
	    if (!expr.info.isImmutable)
		throw new NotImmutable (expr.info);
	    if (!(cast (BoolValue) expr.info.value).isTrue) {
		throw new StaticAssertFailure (this._token, msg ? msg.info.value.toString : this._expr.prettyPrint ());
	    }
	} else {
	    Table.instance.retInfo.returned ();
	}
	
	return new Assert (this._token, expr, msg, this._isStatic);	
    }

    override Instruction templateReplace (Expression [string] values) {
	if (this._msg) 
	    return new Assert (this._token,
			       this._expr.templateExpReplace (values),
			       this._msg.templateExpReplace (values), this._isStatic);
	else
	    return new Assert (this._token,
			       this._expr.templateExpReplace (values),
			       null, this._isStatic);	
    }


    override void print (int nb = 0) {
	writefln ("%s<Assert> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._expr.print (nb + 4);
	if (this._msg) this._msg.print (nb + 4);
    }
    
}

