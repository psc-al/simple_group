const pageload = require("./pageload");

pageload.onPageLoad(function() {
    console.log("loaded");
    let link = document.getElementById("link");
    let text = document.getElementById("text");
    let url_wrapper = document.getElementById("url_wrapper");
    let body_wrapper = document.getElementById("body_wrapper");
    url_wrapper.lastChild.toggleAttribute("required");
    link.addEventListener('change', function() {
        url_wrapper.style.display = "initial";
        url_wrapper.lastChild.toggleAttribute("disabled");
        url_wrapper.lastChild.toggleAttribute("required");
        body_wrapper.style.display = "none";
        body_wrapper.lastChild.toggleAttribute("disabled");
        body_wrapper.lastChild.toggleAttribute("required");
    });
    text.addEventListener('change', function() {
        body_wrapper.style.display = "initial";
        body_wrapper.lastChild.toggleAttribute("disabled");
        body_wrapper.lastChild.toggleAttribute("required");
        url_wrapper.style.display = "none";
        url_wrapper.lastChild.toggleAttribute("disabled");
        url_wrapper.lastChild.toggleAttribute("required");
    });
});
