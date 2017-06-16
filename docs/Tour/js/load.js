$(document).ready (function () {
    var elem = document.getElementById ("home");
    loadContent (elem);
});


function loadContent (element) {
    var name = element.getAttribute ("value");
    var title = element.getAttribute ("title");
    
    $.ajax ({
	dataType: 'html',
	context: this,
	url: "pages/" + name
    }).done (function (data) {
	var page = document.getElementById ("content_page");
	// var parser = new DOMParser ();
	// var other = parser.parseFromString (data, 'text/html');
	
	// while (page.children.length > 0) {
	//     page.removeChild (page.children [0]);
	// }
	
	page.innerHTML = (data);
	reloadScripts ();
	setAce ();
    });
    
}

function setAce () {
    var codes = $(".editor");
    var minTotal = 15;
    for (var i = 0; i < codes.length ; i++) {
	var content = codes [i].getAttribute ("value");
	var min = codes [i].getAttribute ("min");
	console.log (min);
	if (min && parseInt (min))
	    if (minTotal < parseInt (min)) minTotal = parseInt (min);
	
	$.ajax ({
	    dataType : 'text',
	    context: this,
	    async: false,
	    url: "codes/" + content
	}).done (function (data) {
	    console.log (data);
	    codes [i].innerHTML = data;
	    var editor = ace.edit(codes [i]);
	    editor.setTheme("ace/theme/tomorrow");
	    editor.getSession().setMode("ace/mode/ymir");
	    
	    editor.getSession().setTabSize(4);
	    codes [i].style.fontSize = '16px';
	    //document.getElementById('editor').style.fontSize='15px';
	    editor.setShowPrintMargin(false);
	    editor.setHighlightActiveLine(false);
	    editor.setReadOnly(true);
	    editor.renderer.setShowGutter(false);
	    
	    editor.setOptions ({
		maxLines : minTotal
	    });
	});
    }
    console.log (minTotal);

}

function reloadScripts () {   
    $('script').each(function () {
        if ($(this).attr('src') != undefined && $(this).attr('src').lastIndexOf('jquery') == -1) {
            var old_src = $(this).attr('src');
	    console.log (old_src);
            var that = $(this);
            $(this).attr('src', '');
	    
            setTimeout(function () {
                that.attr('src', old_src + '?' + new Date().getTime());
            }, 250);
        }
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


