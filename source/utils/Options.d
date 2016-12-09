module utils.Options;
import utils.Singleton;
import std.traits, utils.YmirException;
import std.typecons, std.algorithm, std.string;
import std.path;

alias Option = Tuple!(string, "identifiant", string, "act", string, "lact", int, "type");


enum OptionEnum : Option {
    DEBUG = Option ("debug", "-g", "--debug", 0),
    WALL = Option ("wall", "--Wall", "--Wall", 0),
    TARGET = Option ("target", "-t", "--target", 1),
    ASSEMBLE = Option ("assemble", "-c", "-c", 0),
    COMPILE = Option ("compile", "-S", "-S", 0)
}


class Options {

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

    const (string []) inputFiles () {
	return this._inputFiles;
    }
    
    const (string) getOption (OptionEnum op) {
	auto it = op in this._options;
	if (it !is null) return *it;
	else return null;
    }

    bool isOn (OptionEnum op) {
	auto it = op in this._options;
	if (it !is null) return true;
	else return false;
    }
    
    
    private string [OptionEnum] _options;
    private string [] _inputFiles;
    mixin Singleton!Options;

}
