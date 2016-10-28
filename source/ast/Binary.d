module ast.Binary;
import ast.Expression;
import syntax.Word, ast.Var, utils.YmirException, semantic.pack.Symbol;
import semantic.types.InfoType, semantic.types.UndefInfo, syntax.Tokens;
import std.stdio, std.string, std.outbuffer;

class UninitVar : YmirException {
    
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Variable non initialisé '%s%s%s' :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

}

class UndefinedOp : YmirException {

    this (Word token, Symbol left, Symbol right) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Operateur '%s%s%s' non définis entre les types '%s%s%s' et '%s%s%s' :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, right.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}

class NotLValue : YmirException {

    this (Word token, Symbol type) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: L'element '%s%s%s' de type '%s%s%s' n'est pas une lvalue :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, type.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}


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
    
    override Expression expression () {
	if (this._token == Tokens.EQUAL)
	    return affect ();
	else return normal ();
    }    

    private Expression affect () {
	auto aux = new Binary (this._token);
	aux._right = this._right.expression ();
	aux._left = this._left.expression ();
	if (cast(Type)aux._left !is null) throw new UndefinedVar (aux._left.token);
	else if (aux._left.info.isConst) throw new NotLValue (aux._left.token, aux._left.info);
	if (cast(UndefInfo)(aux._right.info.type) !is null) throw new UninitVar (aux._right.token);
	if (cast(UndefInfo)(aux._left.info.type) !is null) 
	    aux._left.info.type = aux._right.info.type.clone;
	
	auto type = aux._left.info.type.BinaryOp (this._token, aux._right);
	if (type is null) 
	    throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	aux.info = new Symbol (aux._token, type);
	return aux;
    }
    
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
	aux.info = new Symbol (aux._token, type, true);
	return aux;	
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
