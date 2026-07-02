// <![CDATA[
    /*------------------------------------------------------------------------------
    Excerpts from the jsUtilities Library
    Version:        2.1
    Homepage:       http://www.easy-designs.net/code/jsUtilities/
    License:        Creative Commons Attribution-ShareAlike 2.0 License
    http://creativecommons.org/licenses/by-sa/2.0/
    Note:           If you change or improve on this script, please let us know.
    ------------------------------------------------------------------------------*/
    function inArray(needle) {
        for (var i=0; i < this.length; i++) {
            if (this[i] === needle) {
                return i;
            }
        }
        return false;
    }
    function addClass(theClass) {
        if (this.className != '') {
            this.className += ' ' + theClass;
        } else {
            this.className = theClass;
        }
    }
    function lastChildContainingText() {
        var testChild = this.lastChild;
        var contentCntnr = ['p','li','dd'];
        while (testChild.nodeType != 1) {
            testChild = testChild.previousSibling;
        }
        var tag = testChild.tagName.toLowerCase();
        var tagInArr = inArray.apply(contentCntnr, [tag]);
        if (!tagInArr && tagInArr!==0) {
            testChild = lastChildContainingText.apply(testChild);
        }
        return testChild;
    }
    // ]]>
    // <![CDATA[
        /*------------------------------------------------------------------------------
        Function:       footnoteLinks()
        Author:         Aaron Gustafson (aaron at easy-designs dot net)
        Creation Date:  8 May 2005
        Version:        1.3
        Homepage:       http://www.easy-designs.net/code/footnoteLinks/
        License:        Creative Commons Attribution-ShareAlike 2.0 License
        http://creativecommons.org/licenses/by-sa/2.0/
        Note:           This version has reduced functionality as it is a demo of
        the script's development
        ------------------------------------------------------------------------------*/
        function footnoteLinks(containerID,targetID) {
            var container = document.getElementById(containerID);
            var target    = document.getElementById(targetID);
            var h2        = document.createElement('h2');
            addClass.apply(h2,['printOnly']);
            var h2_txt    = document.createTextNode('Links');
            h2.appendChild(h2_txt);
            var coll = container.getElementsByTagName('*');
            var ol   = document.createElement('ol');
            addClass.apply(ol,['printOnly']);
            var myArr = [];
            var thisLink;
            var num = 1 + document.querySelectorAll('.footnotes[role="doc-endnotes"] li').length;
            ol.setAttribute("start", num);
            for (var i=0; i<coll.length; i++) {
                var thisClass = coll[i].className;
                var notImportant =
                    coll[i].classList.contains("tag")
                    || coll[i].classList.contains("p-category")
                    || coll[i].classList.contains("date")
                    || coll[i].classList.contains("p-author")
                    || coll[i].classList.contains("print-hide")
                    || coll[i].classList.contains("no-footnote")
                    ;
                if ( (coll[i].getAttribute('href') ||
                    coll[i].getAttribute('cite')) && ! notImportant) {
                    thisLink = coll[i].getAttribute('href') ? coll[i].href : coll[i].cite;
                    if (thisLink == coll[i].innerText
                        || thisLink == `${coll[i].innerText}/`
                        || thisLink.includes("#fn:")
                        || thisLink.includes("#fnref:")) continue;
                    var note = document.createElement('sup');
                    addClass.apply(note,['printOnly']);
                    var note_txt;
                    var j = inArray.apply(myArr,[thisLink]);
                    if ( j || j===0 ) {
                        note_txt = document.createTextNode(j+1);
                    } else {
                        var li     = document.createElement('li');
                        var li_txt = document.createTextNode(thisLink);
                        li.appendChild(li_txt);
                        ol.appendChild(li);
                        myArr.push(thisLink);
                        note_txt = document.createTextNode(num);
                        num++;
                    }
                    note.appendChild(note_txt);
                    if (coll[i].tagName.toLowerCase() == 'blockquote') {
                        var lastChild = lastChildContainingText.apply(coll[i]);
                        lastChild.appendChild(note);
                    } else {
                        coll[i].parentNode.insertBefore(note, coll[i].nextSibling);
                    }
                }
            }
            target.appendChild(h2);
            target.appendChild(ol);
            addClass.apply(document.getElementsByTagName('html')[0],['noted']);
            return true;
        }
        window.onload = function() {
            footnoteLinks('main-content','main-content');
        }
        // ]]>
