import { defineConfig } from "vite";
import { resolve } from "node:path";

export default defineConfig({
  build: {
    rollupOptions: {
      input: resolve(__dirname, "html/index.html")
    }
  },
  test: {
    environment: "node"
  }
});
