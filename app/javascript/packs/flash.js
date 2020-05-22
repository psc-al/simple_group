function createFlash(flashType, message) {
  let flashBase = document.createElement("label")
  flashBase.classList.add("flash-message");
  let flashCheck = document.createElement("input");
  flashCheck.type = "checkbox";
  flashBase.appendChild(flashCheck);
  let flashMsgDiv = document.createElement("div");
  let flashClose = document.createElement("span");
  flashMsgDiv.classList.add("flash");
  flashMsgDiv.classList.add("flash-" + flashType);
  flashClose.classList.add("flash-close");
  flashClose.appendChild(document.createTextNode("x"));
  flashMsgDiv.appendChild(document.createTextNode(message));
  flashMsgDiv.appendChild(flashClose);
  flashBase.appendChild(flashMsgDiv);
  document.getElementById("flash-container").appendChild(flashBase);
}

export function flashAlert(message) {
  createFlash("alert", message);
}
