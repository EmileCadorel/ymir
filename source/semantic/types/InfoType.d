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
import semantic.types.LongInfo;

alias LInstList function (LInstList, LInstList) InstComp;
alias LInstList function (LInstList, Array!LInstList) InstCompMult;
alias LInstList function (LInstList) InstCompS;
alias LInstList function (InfoType, Expression, Expression) InstPreTreatment;

class ApplicationScore {

    this () {
	this.score = 0;
    }

    this (Word token) {
	this.score = 0;
	this.token = token;
    }
    
    long score;
    Word token;
    string name;
    bool dyn;
    InfoType ret;
    Array!InfoType treat;    
}

class InfoType {

    private InstPreTreatment _leftTreatment = null;
    private InstPreTreatment _rightTreatment = null;
    private InstComp _lintInst = null;
    private InstCompS _lintInstS = null;
    protected InstCompS _destruct = null;
    private InstCompMult _lintInstMult = null;
    private bool _isConst = true;
    
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
		    "long" : &LongInfo.create];
    }    
    
    static InfoType factory (Word word, Expression [] templates) {
	auto it = (word.str in creators);
	if (it !is null) return (*it) (word, templates);
	throw new UndefinedType (word);
    }
    
    ref bool isConst () {
	return this._isConst;
    }

    LSize size () {
	return LSize.NONE;
    }
    
    static bool exist (string name) {
	return (name in creators) !is null;
    }

    string typeString () {
	return "";
    }

    void quit (string namespace) {
    }

    abstract bool isSame (InfoType) ;    
    
    InfoType BinaryOp (Word token, Expression right) {
	return null;
    }

    InfoType BinaryOpRight (Word token, Expression left) {
	return null;
    }

    ApplicationScore CallOp (Word, ParamList) {
	return null;
    }
    
    InfoType UnaryOp (Word token) {
	return null;
    }

    InfoType AccessOp (Word, ParamList) {
	return null;
    }

    InfoType CastOp (InfoType) {
	return null;
    }

    InfoType CompOp (InfoType) {
	return null;
    }
    
    InfoType DotOp (Var) {
	return null;
    }

    InfoType ParamOp () {
	return null;
    }
    
    InfoType ReturnOp () {
	return null;
    }
    
    abstract InfoType clone ();

    abstract InfoType cloneForParam ();
    
    ref InstPreTreatment leftTreatment () {
	return this._leftTreatment;
    }

    /** 
     Utilisé quand on a besoin d'appliquer un pre traitement a l'element de gauche d'une expression
     Example :
     ---
     //a <- ref!int
     a = 10;
     ---
     */
    LInstList leftTreatment (InfoType type, Expression left, Expression right) {
	return this._leftTreatment (type, left, right);
    }
    
    ref InstPreTreatment rightTreatment () {
	return this._rightTreatment;
    }

    /**
     Utilisé quand on a besoin d'appliquer un pre traitement a l'element de droite d'une expression
     Example :
     ---
     //a <- ref!int
     b = a;
     ---
    */
    LInstList rightTreatment (InfoType type, Expression left, Expression right) {
	return this._rightTreatment (type, left, right);
    }

    
    ref InstComp lintInst () {
	return this._lintInst;
    }

    ref InstCompS lintInstS () {
	return this._lintInstS;
    }

    InfoType destruct () {
	return null;
    }

    void setDestruct (InstCompS s) {
	this._destruct = s;
    }
    
    bool isDestructible () {
	return this._destruct !is null;
    }
    
    ref InstCompMult lintInstMult () {
	return this._lintInstMult;
    }

    /// Utilisé pour les operateur multiple
    LInstList lintInst (LInstList left, Array!LInstList rights) {
	return this._lintInstMult (left, rights);
    }

    /// Utilisé pour les operateur binaire
    LInstList lintInst (LInstList left, LInstList right) {
	return this._lintInst (left, right);
    }

    /// Utilisé pour les operateur unaire
    LInstList lintInst (LInstList left) {
	return this._lintInstS (left);
    }

    /// Utilisé pour les destructeur
    LInstList destruct (LInstList elem) {
	return this._destruct (elem);
    }
    
}
