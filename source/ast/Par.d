module ast.Par;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio, std.string;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;
import ast.Tuple, std.array;
import semantic.types.TupleInfo;

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

    /// Le score recupéré à l'analyse sémantique
    private ApplicationScore _score;
    
    this (Word word, Word end, Expression left, ParamList params) {
	super (word);
	this._end = end;
	this._params = params;
	this._left = left;
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
	aux._params = (cast(ParamList)this._params.expression ());
	aux._left = this._left.expression ();
	if (cast (Type) aux._left !is null) throw new UndefinedVar (aux._left.token);
	else if (cast(UndefInfo) aux._left.info !is null) throw new UninitVar (aux._left.token);
	auto type = aux._left.info.type.CallOp (aux._left.token, aux._params);
	if (type is null) {
	    throw new UndefinedOp (this._token, this._end, aux._left.info, aux._params);
	}
	
	if (type.treat.length != aux._params.length) {
	    tuplingParams (type, aux);
	}
	
	aux._score = type;
	aux._info = new Symbol (this._token, type.ret, true);
	if (cast (UndefInfo) type.ret) {
	    throw new TemplateInferType (aux._left.token, aux._score.token);
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
	auto ctuple = new ConstTuple (par._token, par._end, make!(Array!Expression) (par._params.params [score.treat.length - 1 .. $]));
	auto retType = new TupleInfo ();

	foreach (it ; ctuple.params) {
	    retType.params.insertBack (it.info.type);
	}

	ctuple.info = new Symbol (par._token, retType);	
	par._params.params = make!(Array!Expression) (par._params.params [0 .. score.treat.length - 1].array ());
	par._params.params.insertBack (ctuple);
    }
    

    /**
     Returns: le score retourner par l'analyse sémantique
     */
    ApplicationScore score () {
	return this._score;
    }

    /**
     Returns: L'expression de gauche
     */
    Expression left () {	
	return this._left;
    }

    /**
     Returns: Les paramètres de l'expression
     */
    ParamList paramList () {
	return this._params;
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

}
