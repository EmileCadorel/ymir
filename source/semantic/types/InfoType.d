module semantic.types.InfoType;
import syntax.Word, ast.Expression, utils.YmirException;
import std.outbuffer, utils.exception;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.CharInfo, semantic.types.StringInfo;
import semantic.types.FloatInfo, utils.exception;
import lint.LInstList, std.container;
import semantic.pack.UnPureFrame, ast.ParamList;
import ast.Var, semantic.types.VoidInfo, semantic.types.PtrInfo;
import semantic.types.PtrFuncInfo;
import semantic.types.ArrayInfo, lint.LSize, semantic.types.RefInfo;
import semantic.types.LongInfo, semantic.types.StructInfo;
import semantic.types.RangeInfo;
import semantic.types.TupleInfo;
import std.container;


/** Pointeur sur fonction qui transforme un operateur binaire en lint */
alias LInstList function (LInstList, LInstList) InstComp;

/** Pointeur sur fonction qui transforme un operateur multiple en lint */
alias LInstList function (LInstList, Array!LInstList) InstCompMult;

/** Pointeur sur fonction qui transforme une instruction unaire en lint */
alias LInstList function (LInstList) InstCompS;

/** Pointeur sur fonction qui transforme un pre-traitement d'expression en lint */
alias LInstList function (InfoType, Expression, Expression) InstPreTreatment;

/**
 Cette classe sert à enregistrer un score de surcharge pour les appels de fonctions.
 */
class ApplicationScore {

    this () {
	this.score = 0;
    }

    this (Word token, bool variadic = false) {
	this.score = 0;
	this.token = token;
	this.isVariadic = variadic;
    }

    /** le score de la surcharge */
    long score;

    /** l'identifiant de la surcharge */
    Word token;

    /** Le nom du prototype de la surcharge */
    string name;

    /** On est sur un appel dynamique ?*/
    bool dyn;

    /** Le type de retour de la surcharge */
    InfoType ret;

    /** Le cast à appliquer à chaque paramètre avant l'appel */
    Array!InfoType treat;    

    /** Le prototype est variadic */
    bool isVariadic;
}


/**
 Classe ancêtre de toutes informations de type.
 */
class InfoType {

    /** Traitement à appliquer à l'expression de gauche pour la transformer en lint*/
    private InstPreTreatment _leftTreatment = null;

    /** Traitement à appliquer à l'expression de droite pour la transformer en lint*/
    private InstPreTreatment _rightTreatment = null;

    /** Traitement à appliquer au opérande pour la transformer en lint*/
    private InstComp _lintInst = null;

    /** Liste des traitement unaire à appliquer à l'opérande pour la transformer en lint*/
    private Array!(InstCompS) _lintInstS;

    /** Liste des traitement unaire à appliquer à l'opérande de droite pour la transformer en lint*/
    private Array!(InstCompS) _lintInstSR;

    /** Fonction de transformation pour l'appel du destructeur */
    protected InstCompS _destruct = null;

    /** Fonction de transformation pour les opérateur multiple */
    private InstCompMult _lintInstMult = null;

    /** Le type est il constant ? */
    private bool _isConst = true;

    /** Si le type est un attribut de structure, c'est son numéro */
    private ulong _toGet;

    /** Informations supplémentaires que l'on peut passer au lint (inutile pour le moment je crois) */
    private Object [string] _supplInfos;

    /** La liste des types que l'on peut créé grâce à leurs nom */
    static InfoType function (Word, Expression[]) [string] creators;

    static this () {
	creators = ["int" : &IntInfo.create,
		    "bool" : &BoolInfo.create,
		    "string" : &StringInfo.create,
		    "float" : &FloatInfo.create,
		    "char" : &CharInfo.create,
		    "void" : &VoidInfo.create,
		    "ptr" : &PtrInfo.create,
		    "array" : &ArrayInfo.create,
		    "function" : &PtrFuncInfo.create,
		    "ref" : &RefInfo.create,
		    "long" : &LongInfo.create,
		    "range" : &RangeInfo.create,
		    "tuple" : &TupleInfo.create];
    }    

    /**
     Créé une instance de type, en fonction de son nom et de ses templates.
     Params:
     word = l'identifiant du type.
     templates = les templates du type.
     Returns: une instance de type.
     Throws: UndefinedType.
     */
    static InfoType factory (Word word, Expression [] templates) {
	auto it = (word.str in creators);
	if (it !is null) {
	    return (*it) (word, templates);
	}
	throw new UndefinedType (word);
    }

    /**
     Ajoute un créateur de type, à la liste des types 
     Params: 
     name = le nom du type
     Throws: Assert, si le nom existe déjà.
     */
    static void addCreator (string name) {
	creators [name] = &StructCstInfo.create;
    }

    /**
     Supprime un créateur de la liste.
     Params:
     name = le nom du créateur.
     */
    static void removeCreator (string name) {
	creators.remove (name);
    }

    /**
     Params:
     name = un nom de type
     Returns: le type x existe ?
     */
    static bool exist (string name) {
	return (name in creators) !is null;
    }
    
    /**
     Returns: la liste des informations supplémentaire.
     */
    ref Object [string] supplInfos () {
	return this._supplInfos;
    }

    /**
     Returns: l'index du type si il appartient à une strcuture.
     */
    ref ulong toGet () {
	return this._toGet;
    }

    /**
     Returns: Le type est constant ?
     */
    ref bool isConst () {
	return this._isConst;
    }

    /**
     Returns: la taille du type.
     */
    LSize size () {
	return LSize.NONE;
    }

    /**
     Returns: le nom du type
     */
    string typeString () {
	return "";
    }

    /**
     Returns: le nom simplifié du type
     */
    abstract string simpleTypeString () {
	return "";
    }
    
    /**
     Quitte un scope.
     Params:
     namespace = le contexte du scope.
     */
    void quit (string namespace) {
    }

    /**
     Returns: les deux type sont il identique ?
     */
    abstract bool isSame (InfoType) ;    

    /**
     Surcharge des operateur binaire.
     Params:
     token = l'operateur
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    InfoType BinaryOp (Word token, Expression right) {
	return null;
    }

    /**
     Surcharge des operateur binaire de droite.
     Params:
     token = l'operateur
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    InfoType BinaryOpRight (Word token, Expression left) {
	return null;
    }

    /**
     Surcharge de l'operateur d'appel
     Returns: le type résultat ou null.
     */
    ApplicationScore CallOp (Word, ParamList) {
	return null;
    }

    /**
     Surcharge de l'operateur d'iteration.
     Returns: le type résultat ou null.
     */
    InfoType ApplyOp (Array!Var) {
	return null;
    }
    
    /**
     Surcharge de l'operateur unaire.
     Params:
     token = l'operateur.
     Returns: le type résultat ou null.
     */
    InfoType UnaryOp (Word token) {
	return null;
    }

    /**
     Surcharge de l'operateur d'acces.
     Returns: le type résultat ou null.
     */
    InfoType AccessOp (Word, ParamList) {
	return null;
    }

    /**
     Surcharge de l'operateur de cast.
     Returns: le type résultat ou null.
     */
    InfoType CastOp (InfoType) {
	return null;
    }

    /**
     Surcharge de l'operateur de cast automatique.
     Returns: le type résultat ou null.
     */
    InfoType CompOp (InfoType) {
	return null;
    }

    /**
     Returns: Une information de type avec les informations permettant le cast.
     */
    InfoType CastTo (InfoType) {
	return null;
    }

    /**
     Surcharge de l'operateur d'attribut.
     Returns: le type résultat ou null.
     */
    InfoType DotOp (Var) {
	return null;
    }

    /**
     Surcharge de l'operateur d'attribut à partir d'une string.
     Returns: le type résultat ou null.
     */
    final InfoType DotOp (string name) {
	auto word = Word.eof;
	word.str = name;
	return this.DotOp (new Var (word));
    }

    /**
     Surcharge de l'operateur de paramètre (traitement à appliquer quand on passe le type en paramètre).
     Returns: le type résultat ou null.
     */
    InfoType ParamOp () {
	return null;
    }

    /**
     Surcharge de l'operateur de retour (traitement à appliquer quand on retourne le type).
     Returns: le type résultat ou null.
     */
    InfoType ReturnOp () {
	return null;
    }

    /**
     Créée un clone du type, les informations de destruction sont conservé.
     Returns: une instance de type.
     */
    abstract InfoType clone ();

    /**
     Créée un clone du type, les informations de destruction sont remise à zéro.
     Returns: une instance de type.
     */
    abstract InfoType cloneForParam ();

    /**
     Returns: l'information de pre-traitement.
     */
    ref InstPreTreatment leftTreatment () {
	return this._leftTreatment;
    }

    /++
     + Utilisé quand on a besoin d'appliquer un pre traitement a l'element de gauche d'une expression
     + Example :
     + ---
     + //a <- ref!int
     + a = 10;
     + ---
     +/
    LInstList leftTreatment (InfoType type, Expression left, Expression right) {
	return this._leftTreatment (type, left, right);
    }

    /**
     Returns: l'information de pré-traitement de l'operande droite.
     */
    ref InstPreTreatment rightTreatment () {
	return this._rightTreatment;
    }

    /++
     + Utilisé quand on a besoin d'appliquer un pre traitement a l'element de droite d'une expression
     + Example :
     + ---
     + //a <- ref!int
     + b = a;
     + ---
    +/
    LInstList rightTreatment (InfoType type, Expression left, Expression right) {
	return this._rightTreatment (type, left, right);
    }

    /**
     Returns: l'information de transformation en lint.
     */
    ref InstComp lintInst () {
	return this._lintInst;
    }

    /**
     Returns: la liste d'information de transformation unaire en lint.
     */
    ref Array!InstCompS lintInstS () {
	return this._lintInstS;
    }

    /**
     Returns: la liste d'information de transformation unaire en lint de l'operande de droite.
     */
    ref Array!InstCompS lintInstSR () {
	return this._lintInstSR;
    }
    
    /**
     Returns: les informations de destructions du type en sortie de scope.
     */
    InfoType destruct () {
	return null;
    }

    /**
     Met à jour le destructeur du type.
     Params:
     s = le destructeur.
     */
    void setDestruct (InstCompS s) {
	this._destruct = s;
    }

    /**
     Returns: le type a t'il un destructeur ?
     */
    bool isDestructible () {
	return this._destruct !is null;
    }

    /**
     Returns: les informations de transformation d'operateur multiple du lint.
     */
    ref InstCompMult lintInstMult () {
	return this._lintInstMult;
    }

    /**
     Utilisé pour les operateur multiple
     */
    LInstList lintInst (LInstList left, Array!LInstList rights) {
	return this._lintInstMult (left, rights);
    }

    /**
     Utilisé pour les operateur binaire
    */
    LInstList lintInst (LInstList left, LInstList right) {
	return this._lintInst (left, right);
    }

    /**
     Utilisé pour les operateur unaire
    */
    LInstList lintInst (LInstList left, ulong nb = 0) {
	return this._lintInstS [$ - nb - 1] (left);
    }
    
    /**
     Utilisé pour les operateur unaire de droite.
    */
    LInstList lintInstR (LInstList left, ulong nb = 0) {
	return this._lintInstSR [$ - nb - 1] (left);
    }

    /**
     Utilisé pour les destructeur
    */
    LInstList destruct (LInstList elem) {
	return this._destruct (elem);
    }
    
}
