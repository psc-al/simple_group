const pageload = require("./pageload");
const throttle = require("lodash/throttle");

function updateHideOpacity(element, json) {
  if (json.status === "hidden") {
    element.style.opacity = "0.5";
  } else {
    element.style.opacity = "initial";
  }
}

function updateSubmissionElement(element, json, expectedStatus) {
  submissionClass = "submission-" + expectedStatus;
  if (json.status === expectedStatus) {
    element.classList.add(submissionClass);
  } else {
    element.classList.remove(submissionClass);
  }
}

function handleUpdate(element, a, json) {
  if (a.classList.contains("hide")) {
    updateSubmissionElement(element, json, "hidden");
    updateHideOpacity(element, json);
  } else {
    updateSubmissionElement(element, json, "saved");
  }
  a.text = json.text;
}

function handleResponse(element, a, response) {
  if (response.status == 200) {
    response.json().then(json => handleUpdate(element, a, json));
  }
}

function fetchActionResponse(element, a, kind) {
  fetch("/users/submission_actions", {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.getElementsByName("csrf-token")[0].content
    },
    body: JSON.stringify({
      submission_action: {
        kind: kind,
        submission_short_id: element.id
      }
    })
  }).then(response => handleResponse(element, a, response));
}

function setOnClick(element, a, kind) {
  let throttledRequest = throttle(
    fetchActionResponse,
    750,
    { 'trailing': false }
  );
  a.addEventListener("click", function(e) {
    e.preventDefault();
    throttledRequest(element, a, kind);
  });
}

function setupActionLinks(element) {
  setOnClick(element, element.getElementsByClassName("hide")[0], "hidden");
  setOnClick(element, element.getElementsByClassName("save")[0], "saved");
}

pageload.onPageLoad(function() {
  const elements = document.getElementsByClassName("submission");

  for (let i = 0; i < elements.length; i++) {
    setupActionLinks(elements[i]);
  }
});
