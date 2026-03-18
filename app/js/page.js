export const cards = [
  {
    title: "Lint",
    text: "ESLint runs on every push to app/**."
  },
  {
    title: "Deploy",
    text: "GitHub Actions syncs the app files directly to S3."
  },
  {
    title: "Approval",
    text: "A manual approval gates the second deployment step."
  }
];

export function createHeroMarkup() {
  return `
    <section class="hero">
      <p class="eyebrow">GitHub Actions Sample</p>
      <h1>JavaScript deployment sample app</h1>
      <p class="lead">
        This sample project keeps HTML under <code>html/</code> and script files
        under <code>js/</code> to match the requested source layout.
      </p>
    </section>
  `;
}
