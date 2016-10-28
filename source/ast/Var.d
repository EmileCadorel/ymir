module ast.Var;
import ast.Expression, semantic.pack.Table;
import syntax.Word, std.container, semantic.types.InfoType;
import std.stdio, std.string, std.outbuffer, utils.YmirException;
import semantic.pack.Symbol, ast.VarDecl;

class UndefinedVar : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Variable inconnu '%s%s%s' :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}

class UseAsType : YmirException {
    this (Word token) {
	OutBuffer buf = new OutBuffer;
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s : '%s%s%s' n'est pas un type ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
}

class Var : Expression {

    private Array!Expression _templates;

    this (Word ident) {
	super (ident);
    }
    
    this (Word ident, Array!Expression templates) {
	super (ident);
	this._templates = templates;
    }

    void printSimple () {
	writef ("%s", this._token.str);
    }

    override Var expression () {
	if (!isType && this._templates.length == 0) {
	    auto aux = new Var (this._token);
	    aux.info = Table.instance.get (this._token.str);
	    if (aux.info is null) 
		throw new UndefinedVar (this._token);
	    
	    return aux;
	} else return asType ();
    }

    Type asType () {
	auto info = Table.instance.get (this._token.str);
	if (info !is null) throw new UseAsType (this._token);
	else {
	    Expression [] temp;
	    temp.length = this._templates.length;
	    foreach (it ; 0 .. temp.length) {
		temp [it] = this._templates [it].expression;
	    }
	    auto t_info = InfoType.factory (this._token, temp);
	    return new Type (this._token, t_info);
	}
    }
    
    bool isType () {
	auto info = Table.instance.get (this._token.str);
	if (info is null)
	    return InfoType.exist (this._token.str);
	return false;
    }

      
    override void print (int nb = 0) {
	writefln ("%s<Var> %s(%d, %d) %s ",
		  rightJustify ("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column,
		this._token.str);
    }
    
    
}

class TypedVar : Var {

    private Var _type;

    this (Word ident, Var type) {
	super (ident);
	this._type = type;
    }
    
    override Var expression () {
	auto aux = new TypedVar (this._token, this._type.asType ());
	auto info = Table.instance.get (this._token.str);
	if (info !is null) throw new ShadowingVar (this._token, info.sym);
	aux.info = new Symbol (this._token, aux._type.info.type);
	Table.instance.insert (aux.info);
	return aux;
    }
    
    override void print (int nb = 0) {
	writef ("%s<TypedVar> %s(%d, %d) %s ",
		rightJustify ("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column,
		this._token.str);
	this._type.printSimple ();
	writeln ();
    }

}

class Type : Var {
    
    this (Word word, InfoType info) {
	super (word);
	this._info = new Symbol (word, info);
    }
    

}
