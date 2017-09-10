module ymir.semantic.types.InfoType;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.outbuffer, std.container;

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

    /** Si l'appel est dynamique, cette element est le caster de gauche */
    InfoType left;
    
    /** Le type de retour de la surcharge */
    InfoType ret;

    /** Le cast à appliquer à chaque paramètre avant l'appel */
    Array!InfoType treat;    

    /** Les templates de la fonction, si elle est template */
    Expression [string] tmps;
    
    /** Le prototype est variadic */
    bool isVariadic;

    /** Le prototype est dérivé d'une fonction template */
    bool isTemplate;

    /++ La frame a valider si le score est correct (utilisé uniquement dans les variadics templates) +/
    Frame toValidate;
    
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

    
    /** Fonction de transformation pour les opérateur multiple */
    private InstCompMult _lintInstMult = null;

    /** Le type est il constant ? */
    private bool _isConst = true;

    private bool _isStatic = false;

    protected bool _isType = false;
    
    /** Si le type est un attribut de structure, c'est son numéro */
    private ulong _toGet;
    
    /** Si le type à été appelé avec des paramètre templates (par exemple, les fonctions)*/
    private Array!Expression _templates;
    
    /** Informations supplémentaires que l'on peut passer au lint (inutile pour le moment je crois) */
    private Object [string] _supplInfos;

    /**
     La valeur présente dans l'objet (null si non immutable)
    */
    protected Value _value;
    
    /** La liste des types que l'on peut créé grâce à leurs nom */
    static InfoType function (Word, Expression[]) [string] creators;

    static InfoType [string] alias_;
    
    static this () {
	creators = ["int" : &DecimalInfo.create,
		    "uint" : &DecimalInfo.create,
		    "short" : &DecimalInfo.create,
		    "ushort" : &DecimalInfo.create,
		    "byte" : &DecimalInfo.create,
		    "ubyte" : &DecimalInfo.create,
		    "long" : &DecimalInfo.create,
		    "ulong" : &DecimalInfo.create,
		    "bool" : &BoolInfo.create,
		    "string" : &StringInfo.create,
		    "float" : &FloatInfo.create,
		    "char" : &CharInfo.create,
		    "void" : &VoidInfo.create,
		    "p" : &PtrInfo.create,
		    "array" : &ArrayInfo.create,
		    "fn" : &PtrFuncInfo.create,
		    "ref" : &RefInfo.create,
		    "r" : &RangeInfo.create,
		    "t" : &TupleInfo.create];
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
	auto _it_ = (word.str in alias_);
	if (_it_) return _it_.clone ();
	throw new UndefinedType (word);
    }

    /**
     Crée une instance de type, en fonction de son nom et de ses templates
     Params:
     word = l'identifiant du type
     templates = les templates du type
     Returns: une instance de type
     Throws: UndefinedType
     */
    static InfoType factory (Word word, Array!InfoType types) {
	import std.array;
	Array!Expression aux;
	foreach (it ; types) {
	    aux.insertBack (new Type (word, it));
	}
	return factory (word, aux.array);
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
     Ajoute un alias de type
     */
    static void addAlias (string name, InfoType ali) {
	alias_ [name] = ali;
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
     Supprime un créateur de la liste.
     Params:
     name = le nom du créateur.
     */
    static void removeAlias (string name) {
	alias_.remove (name);
    }

    
    /**
     Params:
     name = un nom de type
     Returns: le type x existe ?
     */
    static bool exist (string name) {	
	return (name in creators) || (name in alias_);
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

    ref bool isStatic () {
	return this._isStatic;
    }

    bool isScopable () {
	return false;
    }
    
    bool isType () {
	return this._isType;
    }

    void isType (bool isType) {
	this._isType = isType;
    }
    
    /**
     Returns: La valeur contenant dans l'objet
     */
    ref Value value () {
	return this._value;
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
    void quit (Namespace namespace) {
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
     Surcharge des operateur binaire
     Params:
     token = l'operateur
     right = l'operande droite de l'expression
     Returns: le type résultat ou null
     */
    final InfoType BinaryOp (Word token, InfoType type) {
	auto expr = new Expression (token);
	expr.info = new Symbol (token, type, type.isConst);
	return this.BinaryOp (token, expr);
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
     Surcharge de l'operateur d'attribut.
     Returns: le type résultat ou null.
     */
    InfoType DotExpOp (Expression) {
	return null;
    }
    
    /++
     Surchage de l'operateur '::'
     Returns: un type résultat ou null.
     +/
    InfoType DColonOp (Var) {
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
     Surchage de l'operateur de template
     Returns: le type résultat ou null
     */
    InfoType TempOp (Array!Expression) {
	return null;
    }
    
    /**
     Créée un clone du type, les informations de destruction sont conservé.
     Returns: une instance de type.
     */
    abstract InfoType clone ();

    /**
     Créée un clone du type, les informations de destruction sont remise à zéro, ainsi que les informations de valeur.
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

    static bool isPrimitive (InfoType info) {
	return cast (DecimalInfo) info ||
	    cast (FloatInfo) info ||
	    cast (CharInfo) info ||
	    cast (BoolInfo) info ||
	    cast (VoidInfo) info;	    
    }

    /**
     Returns: le template contenu dans le type à l'indice 'ulong'
     */
    InfoType getTemplate (ulong) {
	return null;
    }

    /++
     Retourne les paramètre templates sur un range (pour les variadics templates).
     Params:
     begin = le nombre de templates avant
     end = le nombre de templates après.
     Example:
     --------
     def foo (T ...) (a : t!(int, T, int)) {
     }

     foo ((1, "r", 't', 7.4, 2));
     // getTemplate (1, 1) -> [string, char, float];
     --------
     Returns: this.templates [begin .. end]
     +/
    InfoType [] getTemplate (ulong bef, ulong af) {
	return [getTemplate (bef)];
    }
    
}
