const pageload = require("./pageload");

pageload.onPageLoad(function() {
  document.getElementById("toggle-password").addEventListener("click", function() {
    let fields = document.getElementById("change-password");
    let new_password = document.getElementById("user_password");
    let new_password_again = document.getElementById("user_password_confirmation");

    fields.classList.toggle("changing-password");
    fields.classList.toggle("hidden");

    if (fields.classList.contains("changing-password")) {
      if (new_password.disabled) {
        new_password.disabled = false;
        new_password.toggleAttribute("required");
      }

      if (new_password_again.disabled) {
        new_password_again.disabled = false;
        new_password_again.toggleAttribute("required");
      }
    } else {
      if (!new_password.disabled) {
        new_password.disabled = true;
      }

      if (!new_password_again.disabled) {
        new_password_again.disabled = true;
      }
    }
  });
});
