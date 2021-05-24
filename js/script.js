document.addEventListener("DOMContentLoaded", function() {
    let external_lis = document.querySelectorAll('div.toc>ul li');
    Array.from(external_lis).forEach(li => {

        li.classList.add("collapsed");
        console.log(Array.from(li.childNodes.values()))

        if (li.hasChildNodes() && Array.from(li.childNodes.values()).some(e => e.nodeType === 1 && e.nodeName == "UL")) {
            li.classList.add("toggle");
        } else {
            li.classList.add("non-toggle");
        };
    });

    let internal_uls = document.querySelectorAll('div.toc>ul li>ul');
    Array.from(internal_uls).forEach(ul => {
        ul.classList.add("collapsed-content");
        ul.classList.add("content-inner");
    });
    Array.from(external_lis).forEach(li => {
        li.addEventListener("click",
            e => {
                e.stopPropagation();
                console.log("external");
                if (li.classList.contains("collapsed")) {
                    li.classList.replace("collapsed", "visible");
                    Array.from(li.children).forEach(ul => {
                        ul.classList.replace("collapsed-content", "visible-content");
                    });
                } else {
                    li.classList.replace("visible", "collapsed");
                    Array.from(li.children).forEach(ul => {
                        ul.classList.replace("visible-content", "collapsed-content");
                    });
                };
            })
    });
});