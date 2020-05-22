import '../latex_styles.sass';
import { renderMathInElement } from "./latex-autorender";

const pageload = require("./pageload");

pageload.onPageLoad(function() {
  const elements = document.getElementsByClassName("latex-container");

  for (let i = 0; i < elements.length; i++) {
    renderMathInElement(elements[i]);
  }
});
