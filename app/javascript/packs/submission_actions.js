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

function setOnClick(element, a, kind) {
  a.addEventListener("click", function(e) {
    e.preventDefault();
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
  });
}

function setupActionLinks(element) {
  setOnClick(element, element.getElementsByClassName("hide")[0], "hidden");
  setOnClick(element, element.getElementsByClassName("save")[0], "saved");
}

const callback = function() {
  const elements = document.getElementsByClassName("submission");

  for (let i = 0; i < elements.length; i++) {
    setupActionLinks(elements[i]);
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
