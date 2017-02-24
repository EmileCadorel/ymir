$(document).ready (function () {
    $.ajax ({
	dataType: 'html',
	context: this,
	url: "pages/Ymir.html"
    }).done (function (data) {
	var page = document.getElementById ("page");
	var parser = new DOMParser ();
	var other = parser.parseFromString (data, 'text/html');

	while (page.children.length > 0) {
	    page.removeChild (page.children [0]);
	}
	
	page.appendChild (other.body);
	
    });    
});

function loadContent (element) {

    var name = element.getAttribute ("value");
    $.ajax ({
	dataType: 'html',
	context: this,
	url: "pages/" + name
    }).done (function (data) {
	var page = document.getElementById ("page");
	var parser = new DOMParser ();
	var other = parser.parseFromString (data, 'text/html');

	while (page.children.length > 0) {
	    page.removeChild (page.children [0]);
	}
	
	page.appendChild (other.body);
	
    });
    
}
