module utils.Options;
import utils.Singleton;
import std.traits, utils.YmirException;
import std.typecons, std.algorithm, std.string;
import std.path;

/**
 le tuple Option est composé :
 <table>
   <li> - d'un identifiant </li>
   <li> - une chaine d'activation </li>
   <li> - une chaine d'activation long format </li>
   <li> - un type (0 ou 1, avec ou sans param) </li> 
    </table>
 */
alias Option = Tuple!(string, "identifiant", string, "act", string, "lact", int, "type");

/**
 Enumeration de options passable au compilateur
*/
enum OptionEnum : Option {
    /** Génére une solution avec les infos de debug */
    DEBUG = Option ("debug", "-g", "--debug", 0),
    /** Affiche tout les warnings à la compile */
    WALL = Option ("wall", "--Wall", "--Wall", 0),
	/** specifie la cible */
    TARGET = Option ("target", "-t", "--target", 1),
	/** ne va pas jusqu'a l'edition de lien, génére des .o */
    ASSEMBLE = Option ("assemble", "-c", "-c", 0),
	/** ne va pas jusqu'a l'édition de lien, génére des .s */
    COMPILE = Option ("compile", "-S", "-S", 0)
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
	foreach (it ; args [1 .. $]) {
	    if (it.length > 0 && it [0] == '-') {
		parseArgument (it);
	    } else if (extension (it) == ".yr") {		
		this._inputFiles ~= [it];
	    } else {
		throw new YmirException ("Format inconnu " ~ extension (it));
	    }
	}
    }
    
    /**
     Vérifie que l'argument est une option, ou un fichier source.
     Throws: YmirException, si l'argument n'existe pas
     */
    private void parseArgument (string arg) {
	if (arg.length >= 2 && arg [1] != '-') {
	    auto it = find !"a.act == b"([EnumMembers!OptionEnum], arg);
	    if (it == []) throw new YmirException ("Option : " ~ arg ~ " non definie");
	    else this._options [it [0]] = "";	    
	} else {
	    foreach (it ; [EnumMembers!OptionEnum]) {
		auto index = indexOf (arg, "=");
		if (it.type == 0 && index == -1) { // --op
		    if (it.lact == arg) {
			this._options [it] = "";
			return;
		    }
		} else if (it.type == 1 && index != -1) { // --op=elem
		    if (it.lact == arg [0 .. index]) {
			this._options [it] = arg [index .. $];
			return;
		    }
		}
	    }
	    throw new YmirException ("Option : " ~ arg ~ " non definie");
	}
    }

    /**
     Returns la liste des fichiers sources
     */
    const (string []) inputFiles () {
	return this._inputFiles;
    }

    /**
     Returns le paramètre de la fonction (si elle n'est pas activé retourne null)
     */
    const (string) getOption (OptionEnum op) {
	auto it = op in this._options;
	if (it !is null) return *it;
	else return null;
    }

    /**
     Returns l'option est elle activé ?
     */
    bool isOn (OptionEnum op) {
	auto it = op in this._options;
	if (it !is null) return true;
	else return false;
    }
    
    /// Les options activés
    private string [OptionEnum] _options;

    /// les fichiers sources à compiler
    private string [] _inputFiles;
    
    mixin Singleton!Options;

}
