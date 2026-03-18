import { describe, expect, it } from "vitest";
import { cards, createHeroMarkup } from "./page.js";

describe("page", () => {
  it("exposes three pipeline cards", () => {
    expect(cards).toHaveLength(3);
  });

  it("renders the sample title in the hero markup", () => {
    expect(createHeroMarkup()).toContain("JavaScript deployment sample app");
  });
});
