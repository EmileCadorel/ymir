module ast.Par;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio, std.string;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;
import ast.Tuple, std.array;
import semantic.types.TupleInfo;
import ast.Dot;
import semantic.types.RefInfo;
import semantic.pack.Table;
import semantic.types.StructInfo;

/**
 Généré à la syntaxe pour l'operateur multiple.
 Example:
 ---
 expression '(' expression* ')'
 ---
 */
class Par : Expression {

    /// la deuxième parenthèse.
    private Word _end;

    /// Les paramètre contenu entre les parenthèses
    private ParamList _params;

    /// L'expression de gauche
    private Expression _left;

    /// L'expression dans le cas d'un dotCall.
    private DotCall _dotCall;
    
    /// Le score recupéré à l'analyse sémantique
    private ApplicationScore _score;

    /// Crée à partir d'une surcharge d'op ?
    private bool _opCall = false;
    
    this (Word word, Word end, Expression left, ParamList params, bool fromOpCall = false) {
	super (word);
	this._end = end;
	this._params = params;
	this._left = left;
	this._left.inside = this;
	this._params.inside = this;
	this._opCall = fromOpCall;
    }

    this (Word word, Word end) {
	super (word);
	this._end = end;
    }

    /**
     Vérification sémantique.
     Pour être juste l'expression de gauche doit surcharger l'operateur '()' (CallOp).
     Et accepter l'expression de droite.
     Throws:
     UndefinedOp, si l'expression est fausse.
     TemplateInferType, si le type de l'expression ne peut être déduit.
     */
    override Expression expression () {
	auto aux = new Par (this._token, this._end);
	if (this._info is null) {
	    try {
		aux._params = (cast(ParamList)this._params.expression ());
		aux._left = this._left.expression ();
		aux._left.inside = this;
		
		if (cast (Type) aux._left !is null) throw new UseAsVar (aux._left.token, aux._left.info);
		else if (cast(UndefInfo) aux._left.info !is null) throw new UninitVar (aux._left.token);
		else if (aux._left.info !is null && aux._left.info.isType) {
		    if (!cast (StructCstInfo) aux._left.info.type)
			throw new UseAsVar (aux._left.token, aux._left.info);
		}
		
		bool dotCall = false;
		if (auto dcall = cast (DotCall) aux._left) {
		    dotCall = true;
		    aux._left = dcall.call;
		    aux._params.params = make!(Array!Expression) ([dcall.firstPar] ~ aux._params.params.array ());
		    aux._dotCall = dcall;
		}

		writeln ("ICI ", aux._left.info.type.typeString);
		auto type = aux._left.info.type.CallOp (aux._left.token, aux._params);

		if (type is null) {		
		    auto call = !dotCall && !this._opCall ? findOpCall (aux) : null;
		    if (!call) {
			writeln ("[");
			foreach (it ; aux._params.params []) 
			    writeln ("\t", it.info.type.typeString, " ", it.prettyPrint);
			writeln ("]");
			
			if (this._end.locus.line != this._token.locus.line || this._end.locus.column == this._token.locus.column)
			    throw new UndefinedOp (this._token, aux._left.info, aux._params);
			throw new UndefinedOp (this._token, this._end, aux._left.info, aux._params);
		    } else return call;
		}
		
		if (type.treat.length != aux._params.length) 
		    tuplingParams (type, aux);
		
		
		aux._score = type;
		aux._info = new Symbol (this._token, type.ret, type.ret.isConst);
		if (cast (UndefInfo) type.ret && this._inside) {
		    throw new TemplateInferType (aux._left.token, aux._score.token);
		}

		if (!aux.info.value) Table.instance.retInfo.changed = true;
		return aux;
	    } catch (YmirException exp) {
		throw exp;
	    }
	} else {
	    /*if (this._info.isDestructible)
	     Table.instance.garbage (this._info);*/
	    aux.info = this._info;
	}
	
	return aux;
	
    }

    /**
     Transforme le dernier type d'un appel en tuple.
     Params:
     score = le score retourner par l'operateur CallOp
     par = l'appel     
     */
    private void tuplingParams (ApplicationScore score, ref Par par) {
	ConstTuple ctuple;	
	ctuple = new ConstTuple (par._token, par._end, make!(Array!Expression) (par._params.params [score.treat.length - 1 .. $]));	
	auto retType = new TupleInfo ();	    
	foreach (it ; ctuple.params) {
	    auto type = it.info.type;
	    retType.params.insertBack (type);
	}	    
	ctuple.info = new Symbol (par._token, retType);
	
	par._params.params = make!(Array!Expression) (par._params.params [0 .. score.treat.length - 1].array ());
	par._params.params.insertBack (ctuple);
    }

    private auto findOpCall (Par aux) {
	import syntax.Keys;
	if (this._left.token == Keys.OPCALL) return null;
	try {
	    auto word = Word (this._token.locus, Keys.OPCALL.descr, true);
	    auto var = new Var (word);
	    auto params = new ParamList (this._token, make!(Array!Expression) (this._left) ~ this._params.params);
	    
	    auto call = new Par (this._token, this._end, var, params, true);
	    return call.expression;
	} catch (YmirException) {
	    return null;
	}
    }       
    

    override Expression templateExpReplace (Expression [string] values) {
	auto params = this._params.templateExpReplace (values);
	auto left = this._left.templateExpReplace (values);
	return new Par (this._token, this._end, left, params);
    }

    override Expression clone () {
	auto ret = new Par (this._token, this._end, this._left.clone(), cast (ParamList) this._params.clone ());
	ret.info = this._info;
	return ret;
    }    
    
    /**
     Returns: le score retourner par l'analyse sémantique
     */
    ref ApplicationScore score () {
	return this._score;
    }

    /**
     Returns: L'expression de gauche
     */
    ref Expression left () {	
	return this._left;
    }

    /**
     Returns: Les paramètres de l'expression
     */
    ref ParamList paramList () {
	return this._params;
    }

    /++
     Returns: 
     +/
    ref DotCall dotCall () {
	return this._dotCall;
    }
    
    /**
     Returns: La liste des paramètres de l'expression
     */
    Array!Expression params () {
	return this._params.params;
    }

    /**
     Affiche l'expression sous forme d'arbre
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Par> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._left.print (nb + 4);
	this._params.print (nb + 4);	
    }

    override string prettyPrint () {
	import std.format;
	return format ("%s %s", this._left.prettyPrint, this._params.prettyPrint);
    }
    
}
