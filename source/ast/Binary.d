module ast.Binary;
import ast.Expression;
import syntax.Word, ast.Var, semantic.pack.Symbol;
import semantic.types.InfoType, semantic.types.UndefInfo, syntax.Tokens;
import utils.exception;
import std.stdio, std.string, std.outbuffer, std.algorithm;


/***
 * Une operation entre deux expression
 * Example:
 * a op b
*/
class Binary : Expression {

    private Expression _left;
    private Expression _right;
    private bool _isRight = false;
    
    this (Word word, Expression left, Expression right) {
	super (word);
	this._left = left;
	this._right = right;
    }

    this (Word word) {
	super (word);
    }

    bool isRight () {
	return this._isRight;
    }
    
    /**
     * Verification semantique        
     */
    override Expression expression () {
	if (this._token == Tokens.EQUAL)
	    return affect ();
	else if (find ([Tokens.DIV_AFF, Tokens.AND_AFF, Tokens.PIPE_EQUAL,
			Tokens.MINUS_AFF, Tokens.PLUS_AFF, Tokens.LEFTD_AFF,
			Tokens.RIGHTD_AFF, Tokens.STAR_EQUAL,
			Tokens.PERCENT_EQUAL, Tokens.XOR_EQUAL,
			Tokens.DXOR_EQUAL, Tokens.TILDE_EQUAL], this._token) != []) 
	    return reaff ();
	else return normal ();
    }    

    /**
     * Verification particuliere pour l'operateur d'affectation qui peut affecter un type a une variable
     */
    private Expression affect () {
	auto aux = new Binary (this._token);
	aux._right = this._right.expression ();
	aux._left = this._left.expression ();
	if (cast(Type)aux._left !is null) throw new UndefinedVar (aux._left.token);
	else if (aux._left.info.isConst) throw new NotLValue (aux._left.token, aux._left.info);
	if (cast(UndefInfo)(aux._right.info.type) !is null) throw new UninitVar (aux._right.token);
	
	auto type = aux._left.info.type.BinaryOp (this._token, aux._right);
	if (type is null) {
	    if (cast (UndefInfo) (aux._left.info.type)) {
		type = aux._right.info.type.BinaryOpRight (this._token, aux._left);
		if (type is null)
		    throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
		
		aux._left.info.type = type;
		aux._left.info.isConst = false;
		aux._isRight = true;		
	    } else 
		  throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	}	
	aux.info = new Symbol (false, aux._token, type);
	return aux;
    }

    /**
     Pour les operateur particulier (+=, *= ...)
     */
    private Expression reaff () {
	auto aux = new Binary (this._token);
	aux._right = this._right.expression ();
	aux._left = this._left.expression ();
	if (cast(Type) aux._left !is null) throw new UndefinedVar (aux._left.token);
	else if (aux._left.info.isConst) throw new NotLValue (aux._left.token, aux._left.info);
	if (cast (UndefInfo) (aux._right.info.type) !is null) throw new UninitVar (aux._right.token);
	else if (cast(UndefInfo) (aux._left.info.type) !is null) throw new UninitVar (aux._left.token);

	auto type = aux._left.info.type.BinaryOp (this._token, aux._right);
	if (type is null) {
	    type = aux._right.info.type.BinaryOpRight (this._token, aux._left);
	    if (type is null) 
		throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	    aux._isRight = true;
	}
	
	aux.info = new Symbol (aux._token, type);
	return aux;	
    }
    
    /**
     * Operation normale ou les types des deux operande doivent etre connu
     */
    private Expression normal () {
	auto aux = new Binary (this._token);
	aux._right = this._right.expression ();
	aux._left = this._left.expression ();
	if (cast(Type)aux._left !is null) throw new UndefinedVar (aux._left.token);
	if (cast(Type)aux._right !is null) throw new UndefinedVar (aux._right.token);
	if (cast(UndefInfo)(aux._right.info.type) !is null) throw new UninitVar (aux._right.token);
	if (cast(UndefInfo)(aux._left.info.type) !is null) throw new UninitVar (aux._left.token);
	auto type = aux._left.info.type.BinaryOp (this._token, aux._right);
	if (type is null) {
	    type = aux._right.info.type.BinaryOpRight (this._token, aux._left);
	    if (type is null) 
		throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	    aux._isRight = true;
	}
	
	aux.info = new Symbol (aux._token, type);
	return aux;	
    }
    
    ref Expression left () {
	return this._left;
    }

    ref Expression right () {
	return this._right;
    }

    override void print (int nb = 0) {
	writefln ("%s<Binary> : %s(%d, %d) %s  ", rightJustify("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column,
		this._token.str);	
	this._left.print (nb + 4);
	this._right.print (nb + 4);
    }
    
}
