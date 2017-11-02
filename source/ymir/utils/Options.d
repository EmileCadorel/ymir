module ymir.utils.Options;
import ymir.utils._;
import std.traits;
import std.typecons, std.algorithm, std.string;
import std.path, std.process;
import std.file;

/**
   le tuple Option est composé :
   <table>
   <li> - d'un identifiant </li>
   <li> - une chaine d'activation </li>
   <li> - une chaine d'activation long format </li>
   <li> - un type (0 ou 1, avec ou sans param) </li> 
   </table>
*/
alias Option = Tuple!(string, "identifiant", string, "act", string, "lact", int, "type", string, "descr");

/**
   Enumeration de options passable au compilateur
*/
enum OptionEnum : Option {
    /** Génére une solution avec les infos de debug */
    DEBUG = Option ("debug", "-g", "--debug", 0, "Ecris les informations de debug dans la solution"),
	/** Affiche tout les warnings à la compile */
	WALL = Option ("wall", "--Wall", "--Wall", 0, "Affiche tous les warnings"),
	/** specifie la cible */
	TARGET = Option ("target", "-t", "--target", 1, "Spécifie la cible"),
	/** ne va pas jusqu'a l'edition de lien, génére des .o */
	ASSEMBLE = Option ("assemble", "-c", "-c", 0, "compile mais ne fait pas l'édition des liens"),
	/** ne va pas jusqu'a l'édition de lien, génére des .s */
	COMPILE = Option ("compile", "-S", "-S", 0, "compile et assemble mais ne fait pas l'édition des liens"),
	/** Ajoute un dossier d'importation de fichier */
	INCLUDE = Option ("include", "-I", "-I", 1, "Ajoute un dossier d'imporation de module"),
	/** Surcharge la variable d'envirronement YS_HOME */
	YS_PATH = Option ("ys_path", "--YS_PATH", "--YS_PATH", 1, "Spécifie l'emplacement de l'envirronnement de Ymir"),
	/** On compile la std*/
	STD_COMPILATION = Option ("std_compil", "--std", "--std", 0, "Ajoute les fonctions précompilé du langage à la solution"),
	LINT = Option ("lint", "-l", "--lint", 1, "choisis le langage intermidiaire utilisé"),
	OUTLINT = Option ("outlint", "-ol", "--outlint", 0, "Génère le fichier de langage intermediaire"),
	VERBOSE = Option ("verbose", "--verbose", "--verbose", 0, "mode verbose"),
	OUTFILE = Option ("outfile", "-o", "--outfile", 1, "fichier de sortie")
	}

/**
   Classe Singleton qui gére le paramètre passé par l'utilisateur
*/
class Options {

    /**
       Initialise les options
       Params:
       args = les paramètre passé au programme.
    */
    void init (string [] args) {
	for (auto it = 1 ; it < args.length; it++) {
	    string next = null;
	    if (it < args.length - 1) next = args [it + 1];
	    if (args [it].length > 0 && args [it] [0] == '-') {
		if (parseArgument (args [it], next)) it ++;
	    } else if (extension (args [it]) == ".yr") {		
		this._inputFiles ~= [args [it]];
	    } else if (extension (args [it]) == ".a") {
		this._libs ~= [args [it]];
	    } else if (extension (args [it]) == ".o") {
		this._libs ~= [args [it]];
	    } else {
		throw new YmirException ("Format inconnu " ~ extension (args [it]));
	    }
	}

	this._ysPath = environment.get ("YS_PATH");	
	if (!this._ysPath) {
	    auto it = OptionEnum.YS_PATH in this._options;
	    if (!it)
		throw new YmirException ("YS_PATH n'existe pas");
	}
    }
    
    /**
       Vérifie que l'argument est une option, ou un fichier source.
       Throws: YmirException, si l'argument n'existe pas
    */
    private bool parseArgument (string arg, string next) {
	if (arg.length >= 2 && arg [1] != '-') {
	    if (arg [0 .. 2] == "-l") {
		this._links ~= [arg];
		return false;
	    } else {
		auto it = find !"a.act == b"([EnumMembers!OptionEnum], arg);
		if (it == []) throw new YmirException ("Option : [" ~ arg ~ "] non definie" ~ this.help ());
		else {
		    if (it [0].type == 0) {
			this._options [it [0]] = "";
			return false;
		    } else if (next != null) {
			this._options [it [0]] = next;
			return true;
		    } else throw new YmirException ("Option : Manque un nom après [" ~ arg ~ "] " ~ this.help ());
		}
	    }
	} else {
	    foreach (it ; [EnumMembers!OptionEnum]) {
		auto index = indexOf (arg, "=");
		if (index == -1) { // --op
		    if (it.lact == arg && it.type == 0) {
			this._options [it] = "";
			return false;
		    } else if (it.lact == arg && it.type == 1) {
			if (next != null) {
			    this._options [it] = next;
			    return true;
			} else throw new YmirException ("Option : Manque un nom après [" ~ arg ~ "] " ~ this.help ());
		    }
		} else if (it.type == 1 && index != -1) { // --op=elem
		    if (it.lact == arg [0 .. index]) {
			this._options [it] = arg [index + 1 .. $];
			return false;
		    }
		}
	    }
	    throw new YmirException ("Option : " ~ arg ~ " non definie");
	}
    }

    private string help () {
	import std.outbuffer, std.format, std.string;
	auto buf = new OutBuffer ();
	buf.writefln ("\nusage [options] file...\nOptions:");
	foreach (it ; [EnumMembers!OptionEnum]) {
	    buf.writefln ("\t%s\t%s", leftJustify (format("%s, %s", it.act, it.lact), 20, ' '), it.descr);
	}
	buf.writefln ("\nPour signaler un bug, aller sur :\nhttps://github.com/EmileCadorel/ymir/");
	return buf.toString ();
    }    

    /**
       Returns la liste des fichiers sources
    */
    const (string []) inputFiles () {
	return this._inputFiles;
    }

    /**
       Returns: la liste des fichiers libs
    */
    const (string []) libs () {
	string [] libs;
	string name = this._ysPath;

	if (this._ysPath.length > 0) {
	    name = this._ysPath ~ (this._ysPath [$ - 1] == '/' ? "libs/" : "/libs/");
	}	
	
	foreach (it ; dirEntries (name, SpanMode.breadth)
		 .filter!(f => (f.name.endsWith (".o") || f.name.endsWith (".a")))
		 .map!(a => a.name)) {
	    libs ~= [it];
	}
	
	return this._libs ~ libs;
    }
    
    /**
       Returns le paramètre de la fonction (si elle n'est pas activé retourne null)
    */
    const (string) getOption (OptionEnum op) {
	auto it = op in this._options;
	if (it !is null) return *it;
	else return null;
    }

    const (string[]) links () {
	return this._links;
    }
    
    /**
       Returns: Le path YS_PATH
    */
    const (string) getPath () {
	auto it = OptionEnum.YS_PATH in this._options;
	if (it !is null) return *it;
	return this._ysPath;
    }
    
    /**
       Returns l'option est elle activé ?
    */
    bool isOn (OptionEnum op) {
	auto it = op in this._options;
	if (it !is null) return true;
	else return false;
    }
    
    /**  Les options activés */
    private string [OptionEnum] _options;

    /**  les fichiers sources à compiler*/
    private string [] _inputFiles;

    /** Fichier .o et .a */
    private string [] _libs;

    /** -l.. */
    private string [] _links;
    
    /** le path YS_PATH */
    private string _ysPath;
    
    mixin Singleton!Options;

}
