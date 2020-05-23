const pageload = require("./pageload");

function setReplyOnClick(a) {
  a.addEventListener("click", function(e) {
    e.preventDefault();
    let parentId = a.closest(".comment").id;
    let replyBox = document.getElementById("reply_" + parentId);
    replyBox.style.display = "block";
  });
}

pageload.onPageLoad(function() {
  const replyLinks = document.getElementsByClassName("reply");

  for (let i = 0; i < replyLinks.length; i++) {
    setReplyOnClick(replyLinks[i]);
  }

  const cancel_buttons = document.getElementsByClassName("cancel-reply");

  for(let i = 0; i < cancel_buttons.length; i++) {
    let b = cancel_buttons[i];
    b.addEventListener("click", function(e) {
      b.closest(".comment-reply-box").style.display = "none";
    });
  }

  const hide_button_controls = document.getElementsByClassName("hide-comment");

  for(let i = 0; i < hide_button_controls.length; i++) {
    let hide_button = hide_button_controls[i];
    hide_button.addEventListener("click", function(e) {
      let comment = hide_button.closest(".comment");
      let content = document.getElementById("comment_content_" + comment.id);
      let scoring = document.getElementById("scoring_" + comment.id);
      if (content.style.display === "none") {
        hide_button.classList.remove("hidden");
        content.style.removeProperty("display");
        scoring.style.removeProperty("display");
        comment.style.removeProperty("grid-row-gap");

      } else {
        hide_button.classList.add("hidden");
        content.style.display = "none";
        scoring.style.display = "none";
        comment.style.gridRowGap = "0";
      }
    });
  }
});
