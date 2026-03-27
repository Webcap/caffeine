#!/usr/bin/env node
/**
 * Local config server for Caffeine app development.
 * Serves GET /config with mock JSON. No dependencies required.
 *
 * Run: node tools/run_config_server.js
 * Then set CAFFEINE_API_URL=http://localhost:8080 in .env
 * (Use http://10.0.2.2:8080 for Android emulator)
 */
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 8080;
const configPath = path.join(__dirname, "config.json");

const config = JSON.parse(fs.readFileSync(configPath, "utf-8"));

const server = http.createServer((req, res) => {
  if (req.method === "GET" && (req.url === "/config" || req.url === "/config/")) {
    res.writeHead(200, { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" });
    res.end(JSON.stringify(config));
  } else {
    res.writeHead(404);
    res.end("Not found");
  }
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Config server running at http://localhost:${PORT}/config`);
  console.log("Set CAFFEINE_API_URL=http://localhost:8080 in .env");
  console.log("For Android emulator: CAFFEINE_API_URL=http://10.0.2.2:8080");
});
