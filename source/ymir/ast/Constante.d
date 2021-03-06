module ymir.ast.Constante;
import ymir.ast.Expression;
import ymir.syntax._;
import ymir.lint._;
import ymir.semantic._;
import ymir.utils._;

import std.stdio, std.string, std.conv;
import std.math, std.container;
import std.typecons;

struct DecType {
    string name;
    string sname;
    int id;
}

enum DecimalConst : DecType {
    BYTE = DecType ("byte", "g", 0),
    UBYTE = DecType ("ubyte", "h", 1),
    SHORT = DecType ("short", "s", 2),
    USHORT = DecType ("ushort", "t", 3),
    INT = DecType ("int", "i", 4),
    UINT = DecType ("uint", "k", 5),
    LONG = DecType ("long", "l", 6),
    ULONG = DecType ("ulong", "m", 7)
}


LSize fromDecimalConst (DecimalConst size) {    
    final switch (size.id) {
    case DecimalConst.BYTE.id : return LSize.BYTE;
    case DecimalConst.UBYTE.id : return LSize.UBYTE;
    case DecimalConst.SHORT.id : return LSize.SHORT;
    case DecimalConst.USHORT.id : return LSize.USHORT;
    case DecimalConst.INT.id : return LSize.INT;
    case DecimalConst.UINT.id : return LSize.UINT;
    case DecimalConst.LONG.id : return LSize.LONG;
    case DecimalConst.ULONG.id : return LSize.ULONG;
    }
}

bool isSigned (DecimalConst dec) {
    return dec.id % 2 == 0;
}

/**
 Example : 
 ----
 132
 ---
 */
class Decimal : Expression {
    
    private DecimalConst _type;
    
    this (Word word, DecimalConst type) {
	super (word);
	this._type = type;
    }

    /**
     Vérification sémantique.
     Toujours Ok.
     */
    override Expression expression () {
	auto aux = new Decimal (this._token, this._type);
	aux.info = new Symbol (this._token, new DecimalInfo (true, this._type));
	aux.info.value = new DecimalValue (this._token.str);
	return aux;
    }

    override Expression templateExpReplace (Expression[string]) {
	return new Decimal (this._token, this._type);
    }

    override protected Expression onClone () {
	return new Decimal (this._token, this._type);
    }

    override string prettyPrint () {
	return this._token.str;
    }
    
    DecType type () {
	return this._type;
    }
    
    string value () {
	return this._token.str;
    }

}


/**
 Example:
 ---
 'r'
 ---
 */
class Char : Expression {

    private ubyte _code;
    
    this (Word word, ubyte code) {
	super (word);
	this._code = code;
    }

    /**
     Returns: la valeur de la constante.
     */
    ref ubyte code () {
	return this._code;
    }

    /**
     Vérification sémantique.
     Toujours Ok.
     */
    override Expression expression () {
	auto aux = new Char (this._token, this._code);
	aux.info = new Symbol (this._token, new CharInfo (true), true);
	aux.info.value = new CharValue (this._code);
	return aux;
    }

    override Expression templateExpReplace (Expression [string]) {
	return this.clone ();
    }

    override protected Expression onClone () {
	return new Char (this._token, this._code);
    }
    
    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb =  l'offset courant
    */
    override void print (int nb = 0) {
	writefln ("%s<Char> %s(%d, %d) %d"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._code);	
   } 

    override string prettyPrint () {
	return to!string (cast (char) (this._code));
    }
    
}


/**
 Example:
 ---
 12.
 ---
 */
class Float : Expression {

    /// L'élement après la virgule
    private string _suite;

    /// Tout le flottant
    private string _totale;
    
    this (Word word, string suite) {
	super (word);
	this._suite = suite;
	this._totale = this._token.str ~ "." ~ this._suite;
    }
    
    this (Word word) {
	super (word);
	this._totale = "." ~ this._token.str;
    }

    this (string totale, Word word) {
	super (word);
	this._totale = totale;
    }

    /**
     Vérification sémantique.
     Toujours Ok.
     */
    override Expression expression () {
	auto aux = new Float (this._totale, this._token);
	aux.info = new Symbol (this._token, new FloatInfo (true), true);
	return aux;
    }

    override Expression templateExpReplace (Expression [string]) {
	return this.clone ();
    }

    override protected Expression onClone () {
	return new Float (this._totale, this._token);
    }
    
    /**
     Returns: la valeur de la constante sous forme de string
     */
    string totale () const {
	return this._totale;
    }

    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb =  l'offset courant
    */
    override void print (int nb = 0) {
	writefln ("%s<Float> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._totale);
	
   }

    override string prettyPrint () {
	return to!string (this._totale);
    }
    
}

/**
 Example:
 ---
 'salut'
 "comment"
 ---
*/
class String : Expression {

    private string _content;    
    private char [string] _escape;
    private ulong _label;
    private static ulong [string] __labels__;
    private static ulong __last__;
    
    this (Word word, string content) {
	super (word);
	this._content = content;
	this._escape = ["\\a": '\a', "\\b" : '\b', "\\f" : '\f',
			    "\\n" : '\n', "\\r" : '\r', "\\t" : '\t',
			    "\\v" : '\v', "\\" : '\\',  "\\'" : '\'',
			    "\\\"" : '\"', "\\?": '\?'];   
    }

    this (string content) {
	super (Word.eof);
	this._content = content;
    }
    
    /**
     Convertis un escapeChar hexadecimale en nombre
     */
    private short fromHexa (string elem) {
	short total = 0;
	ulong size = elem.length - 1;
	foreach (it ; elem [0 .. $]) {
	    if (it >= 'a')
		total += pow (16, size) * (it - 'a');
	    else
		total += pow (16, size) * (it - '0');
	    size -= 1;
	}
	return total;
    }

    /**
     Convertis un escapeChar Octal en nombre
     */
    private short fromOctal (string elem) {
	short total = 0;
	ulong size = elem.length - 1;
	foreach (it ; elem [0 .. $]) {
	    if (it >= 'a')
		total += pow (8, size) * (it - 'a');
	    else
		total += pow (8, size) * (it - '0');
	    size -= 1;
	}
	return total;
    }

    /**
     Récupere un escapeChar Hexa dans la chaine et le convertie en nombre
     */
    private short getFromLX (ref string elem, ref ulong index) {
	int size = 0;
	foreach (it ; elem [2 .. $])
	    if ((it < 'a' || it > 'f') && (it < '0' || it > '9'))
		break;
	    else size ++;
	if (size < 1) return -1;
	size = size > 2 ? 2 : size;
	index += size + 2;
	auto escape = elem [2 .. size + 2];
	elem = elem [size + 2 .. $];
	return fromHexa (escape);
    }

    /**
     Récupere un escapeChar Octal dans la chaine et le convertie en nombre
     */
    private short getFromOc (ref string elem, ref ulong index) {
	if (elem [1] < '0' || elem [1] > '7') return -1;
	int size = 0;
	foreach (it ; elem [2 .. $])
	    if (it < '0' || it > '7') break;
	    else size ++;
	size = size > 4 ? 4 : size;
	auto escape = elem [1 .. size + 2];
	elem = elem [size + 2 .. $];
	index += size + 1;
	return fromOctal (escape);
    }
    
    
    /**
     Vérifie que le pointeur est bien sur un élément de type char.
     Params:
     elem = la chaine à vérifier
     index = le pointeur courant
     */
    private short isChar (ref string elem, ref ulong index) {
	if (elem.length == 1) {
	    char c = elem [0];
	    elem = "";
	    return c;
	}
	
	auto val = elem [0 .. 2] in this._escape;
	if (val !is null) {
	    elem = elem [2 .. $];
	    index += 2;
	    return *val; 
	} else if (elem [0] != Keys.ANTI.descr[0]) {
	    char c = elem [0];
	    elem = elem [1 .. $];
	    index += 1;
	    return c;
	} else {
	    if (elem.length > 1) {
		if (elem [1] == Keys.LX.descr [0]) {
		    return getFromLX (elem, index);
		} else {
		    return getFromOc (elem, index);
		}
	    }	    
	}
	return -1;
    }

    /**
     Vérification sémantique.
     Pour être juste la chaine ne doit pas contenir de char qui n'en sont pas.
     Throws: UndefinedEscapeChar
     */
    override Expression expression () {
	ulong index = 0;
	string begin = this._content, end = "";
	while (begin != "") {
	    short s = isChar (begin, index);
	    if (s == -1) throw new UndefinedEscapeChar (this._token, index, begin [0 .. 2]);
	    end ~= to!char (s);
	}
	
	auto aux = new String (this._token, this._content);	
	aux._content = end;
	auto it = end in __labels__;
	if (it is null) {
	    __labels__ [end] = __last__;
	    aux._label = __last__;
	    __last__ ++;
	} else aux._label = *it;
	
	aux.info = new Symbol (this._token, new StringInfo (true), true);
	aux.info.value = new StringValue (this._content);
	return aux;       
    }

    ulong getLabel () {
	return this._label;
    }
    
    override protected Expression onClone () {
	return new String (this._token, this._content);
    }
    
    override Expression templateExpReplace (Expression [string]) {
	return this.clone ();
    }
    
    /**
     Returns: la valeur de la constante
     */
    ref string content () {
	return this._content;
    }

    override string prettyPrint () {
	return "'" ~ this._content ~ "'";
    }

    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb =  l'offset courant
    */
    override void print (int nb = 0) {
	writefln ("%s<String> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._content);
    }
    
}

class Bool : Expression {
    this (Word word) {
	super (word);
    }

    /**
     Vérification sémantique.
     Toujours Ok.
     */
    override Expression expression () {
	auto aux = new Bool (this._token);
	aux.info = new Symbol (this._token, new BoolInfo (true), true);
	aux.info.value = new BoolValue (this._token == Keys.TRUE ? true : false);
	return aux;
    }

    /**
     Returns: La valeur de la constante
     */
    bool value () {
	return this._token.str == "true";
    }

    override Expression templateExpReplace (Expression [string]) {
	return this.clone ();
    }
    
    override protected Expression onClone () {
	return new Bool (this._token);
    }

    override string prettyPrint () {
	return this._token.str;
    }
    
    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb =  l'offset courant
    */
    override void print (int nb = 0) {
	writefln ("%s<Bool> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
    }

    
}

class Null : Expression {

    this (Word word) {
	super (word);
    }

    /**
     Vérification sémantique.
     Toujours Ok.
     */
    override Expression expression () {
	auto aux = new Null (this._token);
	aux.info = new Symbol (this._token, new NullInfo (), true);
	return aux;
    }

    override Expression templateExpReplace (Expression [string]) {
	return this.clone ();
    }
    
    override protected Expression onClone () {
	return new Null (this._token);
    }

    override string prettyPrint () {
	return "null";
    }
    
    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb =  l'offset courant
    */
    override void print (int nb = 0) {
	writefln ("%s<Null> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
    }
    
}

