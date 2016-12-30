module ast.System;
import ast.Expression, syntax.Word, std.container, std.stdio, std.string;
import semantic.types.VoidInfo, semantic.types.IntInfo, semantic.pack.Symbol;
import semantic.types.FloatInfo, semantic.types.CharInfo;

/**
 Classe généré à la syntaxe par.
 Example:
 ---
 'system' '(' Identifiant ',' expression* ')'
 ---
 */
class System : Expression {

    /// Les paramètre de l'expression
    private Array!Expression _params;
    
    this (Word id, Array!Expression params) {
	super (id);
	this._params = params;
    }
    
    /**
     Analyse sémantique.
     Pour être correct les paramètre doivent l'être.     
     */
    override Expression expression () {
	Array!Expression expr;
	foreach (it ; this._params)
	    expr.insertBack (it.expression);
	
	auto aux = new System (this._token, expr);
	aux.info = this._getSymbol ();
	return aux;
    }
    
    private Symbol _getSymbol () {
	if (this._token.str == "scan_i") return new Symbol (this._token, new IntInfo ());
	if (this._token.str == "scan_f") return new Symbol (this._token, new FloatInfo ());
	if (this._token.str == "scan_c") return new Symbol (this._token, new CharInfo ());
	else return new Symbol (this._token, new VoidInfo ());
    }

    /**
     Returns les paramètres de l'expression
     */
    Array!Expression params () {
	return this._params;
    }

    /**
     Affiche l'expression sous forme d'arbre
     Params: 
     nb = L'offset courant.
     */
    override void print (int nb = 0) {
	writefln ("%s<System> %s(%d, %d) : %s",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	foreach (it ; this._params)
	    it.print (nb + 4);
    }
    
}
