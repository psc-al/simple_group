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
      let commentId = hide_button.closest(".comment").id;
      let commentTree = document.getElementById("tree_" + commentId);
      let replies = document.getElementById("replies_" + commentId);
      let upvote = document.getElementById("upvote_" + commentId);
      let downvote = document.getElementById("downvote_" + commentId);
      if (commentTree.style.display === "none") {
        hide_button.classList.remove("hidden");
        commentTree.style.display = "initial";
        replies.style.display = "initial";
        upvote.style.display = "initial";
        downvote.style.display = "initial";

      } else {
        hide_button.classList.add("hidden");
        commentTree.style.display = "none";
        replies.style.display = "none";
        upvote.style.display = "none";
        downvote.style.display = "none";
      }
    });
  }
});
