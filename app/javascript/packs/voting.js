const throttle = require("lodash/throttle");
const flash = require("./flash");

function getOppositeControl(shortId, voteControl) {
  if (voteControl.id.startsWith("upvote_")) {
    return document.getElementById("downvote_" + shortId);
  } else if (voteControl.id.startsWith("downvote_")) {
    return document.getElementById("upvote_" + shortId);
  }
}

function handleRemovedVote(votableElement, voteControl) {
  if (voteControl.id.startsWith("upvote_")) {
    voteControl.classList.remove("upvoted");
  } else if (voteControl.id.startsWith("downvote_")){
    voteControl.classList.remove("downvoted");
  }
}

function handleUpdate(votableElement, voteControl, json) {
  if (json.action === "removed") {
    handleRemovedVote(votableElement, voteControl);
  } else {
    voteControl.classList.add(json.action);
    handleRemovedVote(votableElement, getOppositeControl(votableElement.id, voteControl));
  }
}

function handleResponse(votableElement, voteControl, response) {
  response.json().then(json => {
    if (response.status == 200) {
      handleUpdate(votableElement, voteControl, json);
    } else if (response.status == 403 && json.info !== null) {
      flash.flashAlert(json.info);
    }
  });
}

function baseResourcePath(shortId) {
  if (shortId.startsWith("s_")) {
    return "/api/v1/submissions";
  } else if (shortId.startsWith("c_")) {
    return "/api/v1/comments";
  }
}

function fetchVoteResponse(votableElement, path, voteControl) {
  fetch(path, {
    method: "PUT",
    headers: { "X-CSRF-Token": document.getElementsByName("csrf-token")[0].content }
  }).then(response => handleResponse(votableElement, voteControl, response));
}

function setVoteListener(votableElement, dir) {
  let shortId = votableElement.id;
  let path = baseResourcePath(shortId) + "/" + shortId + "/" + dir + "votes";
  let voteControl = document.getElementById(dir + "vote_" + shortId);
  throttledRequest = throttle(fetchVoteResponse,
    750,
    { 'trailing': false }
  );
  voteControl.addEventListener("click", function(e) {
    throttledRequest(votableElement, path, voteControl)
  });
}

const callback = function() {
  const votableElements = document.getElementsByClassName("votable");

  for (let i = 0; i < votableElements.length; i++) {
    setVoteListener(votableElements[i], "up");
    setVoteListener(votableElements[i], "down");
  }
};

if (
    document.readyState === "complete" ||
    (document.readyState !== "loading" && !document.documentElement.doScroll)
) {
  callback();
} else {
  document.addEventListener("DOMContentLoaded", callback);
}
