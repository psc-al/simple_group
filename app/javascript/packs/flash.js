function createFlash(flashType, message) {

  let flashBase = document.createElement("div")
  flashBase.classList.add("flash");
  flashBase.classList.add("flash-" + flashType);

  let flashMsg = document.createElement("p");
  flashMsg.innerHTML = message;
  flashBase.appendChild(flashMsg);

  let flashClose = document.createElement("span");
  flashClose.classList.add("flash-close");
  flashClose.appendChild(document.createTextNode("x"));
  flashBase.appendChild(flashClose);

  document.getElementById("flash-container").appendChild(flashBase);
  flashBase.addEventListener("click", function() {
      flashBase.remove();
  });
  setTimeout(function(){ 
      flashBase.remove();
  }, 10000);
}

export function flashAlert(message) {
  createFlash("alert", message);
}
