const pageload = require("./pageload");
const throttle = require("lodash/throttle");

function handleResponse(actionLink, response) {
  if (response.status == 200) {
    response.json().then(json => actionLink.text = json.text);
  }
}

function fetchActionResponse(actionLink) {
  id = actionLink.id.slice("thread-reply-action-".length);
  fetch("/inbox/thread_reply_notifications/" + id, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.getElementsByName("csrf-token")[0].content
    }
  }).then(response => handleResponse(actionLink, response));
}

pageload.onPageLoad(function() {
  let checkBoxes = document.querySelectorAll(".inbox-filters-container input[type='checkbox']");
  let form = document.querySelector(".inbox-filters-container form");
  let actionLinks = document.querySelectorAll(".thread-reply-container .actions a");
  let throttledRequest = throttle(
    fetchActionResponse,
    750,
    { 'trailing': false }
  );

  for (const checkBox of checkBoxes) {
    checkBox.addEventListener('change', function() {
      form.submit();
    });
  }

  for (const actionLink of actionLinks) {
    actionLink.addEventListener("click", function(e) {
      e.preventDefault();
      throttledRequest(actionLink);
    });
  }
});
