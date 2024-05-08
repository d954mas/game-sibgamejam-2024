var LibHtmlUtils = {


    HtmlHtmlUtilsHideBg: function () {
        let bg = document.getElementById("image-overlay");
        if (bg) {
            bg.style.display = "none";
            bg.style.background = "";
            bg.remove()
        }
    },

    HtmlHtmlUtilsCanvasFocus: function () {
        document.getElementById("canvas").focus()
    },

}

addToLibrary(LibHtmlUtils);