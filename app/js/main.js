// rollback-check: version 1
import { cards, createHeroMarkup } from "./page.js";
import "./styles.css";

const root = document.querySelector("#root");

if (!root) {
  throw new Error("Root element '#root' was not found.");
}

const cardsMarkup = cards
  .map(
    (card) => `
      <article class="card">
        <h2>${card.title}</h2>
        <p>${card.text}</p>
      </article>
    `
  )
  .join("");

root.innerHTML = `
  <main class="page">
    ${createHeroMarkup()}
    <section class="grid" aria-label="CI pipeline summary">
      ${cardsMarkup}
    </section>
  </main>
`;
