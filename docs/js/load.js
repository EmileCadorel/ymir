$(document).ready (function () {
    $.ajax ({
	dataType: 'html',
	context: this,
	url: "pages/Ymir.html"
    }).done (function (data) {
	var page = document.getElementById ("content");
	var parser = new DOMParser ();
	var other = parser.parseFromString (data, 'text/html');

	while (page.children.length > 0) {
	    page.removeChild (page.children [0]);
	}
	
	page.appendChild (other.body);
	highlight ();
	$('<link rel="stylesheet" type="text/css" href="assets/font-awesome-4.7.0/css/font-awesome.min.css">').prependTo('head');
    });    
});

function loadContent (element) {

    var name = element.getAttribute ("value");
    $.ajax ({
	dataType: 'html',
	context: this,
	url: "pages/" + name
    }).done (function (data) {
	var page = document.getElementById ("content");
	var parser = new DOMParser ();
	var other = parser.parseFromString (data, 'text/html');
	
	while (page.children.length > 0) {
	    page.removeChild (page.children [0]);
	}
	
	page.appendChild (other.body);
	highlight ();
	$('<link rel="stylesheet" type="text/css" href="assets/font-awesome-4.7.0/css/font-awesome.min.css">').prependTo('head');	
    });
    
}

function splitString (str) {
    var aux = str.split (' ');
    var globArray = [];

    for (var i = 0 ; i < aux.length; i++) {
	if (aux [i] == ' ') continue;
	var other = aux [i].split ('\n');
	console.log (other);
	if (other.length != 1) {
	    for (var z = 0; z < other.length; z++)
		if (z < other.length - 1) {
		    globArray.push (other [z]);
		    globArray.push ('\n');
		} else globArray.push (other [z]);
	} else {
	    globArray.push (aux [i]);
	}
	
	if (i < aux.length - 1)
	    globArray.push (' ');
    }
    console.log ((globArray));
    
    return globArray;
}

function highlight () {
    var codes = $('code');
    var i = 0;
    while (i < codes.length) {
	var words = splitString (codes [i].innerHTML);
	final_ = "";
	for (var j = 0; j < words.length; j++) {
	    if (isKey (words [j])) {
		final_ += "<span class=\"hljs-keyword\">" + words [j] + "</span>"
	    } else if (isPrim (words [j])) {
		final_ += "<span class=\"hljs-type\">" + words [j] + "</span>"
	    } else {
		final_ += words [j];
	    }
	}

	codes [i].innerHTML = final_;
	i++;
    }        
}


function isPrim (elem) {
    var keys = ["int", "float", "string", "tuple", "char", "array"];
    
    for (var i = 0; i < keys.length; i++)
	if (keys [i] == elem) return true;
    
    return false;
}  

    
function isKey (elem) {
    var keys = ["import", "struct", "def", "for", "return", "while", "break", "ref",
		"match", "in", "else", "null", "cast", "fn", "let", "is", "extern", "imut",
		"public", "private", "expand", "enum", "assert", "static", "typeof", "mixin", "of"];
    
    for (var i = 0; i < keys.length; i++)
	if (keys [i] == elem) return true;
    
    return false;
}
    
