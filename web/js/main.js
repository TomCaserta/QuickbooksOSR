/// TODO: TURN THIS INTO A CONTROLLER WITH ANGULAR AND MAKE IT MORE EFFICIENT RATHER THAN LOOPING EVERYTHING

$( window ).scroll(function() {
  var topOffset = 50;
  $(".scrollwithview").each(function (elemI) {    
  

     var elem = $(this);
     var isNew = elem.data("first") ? false : true;
     if (isNew) {
      elem.data("first", true); 
      elem.data("origin", elem.offset());
      elem.data("drag-style", JSON.parse(elem.attr("data-drag-style")));
      elem.data("orig-style", css(elem));
     } 
     // http://stackoverflow.com/questions/6215779/scroll-if-element-is-not-visible
     var elementOffset = elem.data("origin");
     var viewportWidth = jQuery(window).width(),
        viewportHeight = jQuery(window).height(),
        documentScrollTop = jQuery(document).scrollTop() - topOffset,
        elementHeight = elem.height(),
        minTop = documentScrollTop,
        maxTop = documentScrollTop + viewportHeight;
    
        
     
    if (elementOffset.top > minTop) {
      if (elem.css("position") != "static") {
        elem.css(elem.data("orig-style"));
        elem.css({ position: "static" });   
      }
    }
    else {
      if (elem.css("position") != "absolute") {
        elem.css(elem.data("drag-style"));
        elem.css({ position: "fixed", display: "block", top: parseInt(elem.attr("data-drag-top"))  });
        
      }
      else {
       // elem.css({ top: documentScrollTop });
      }
    }
    
  });
});

//http://stackoverflow.com/questions/754607/can-jquery-get-all-css-styles-associated-with-an-element

function css(a) {
    var sheets = document.styleSheets, o = {};
    for (var i in sheets) {
        var rules = sheets[i].rules || sheets[i].cssRules;
        for (var r in rules) {
            if (a.is(rules[r].selectorText)) {
                o = $.extend(o, css2json(rules[r].style), css2json(a.attr('style')));
            }
        }
    }
    return o;
}

function css2json(css) {
    var s = {};
    if (!css) return s;
    if (css instanceof CSSStyleDeclaration) {
        for (var i in css) {
            if ((css[i]).toLowerCase) {
                s[(css[i]).toLowerCase()] = (css[css[i]]);
            }
        }
    } else if (typeof css == "string") {
        css = css.split("; ");
        for (var i in css) {
            var l = css[i].split(": ");
            s[l[0].toLowerCase()] = (l[1]);
        }
    }
    return s;
}