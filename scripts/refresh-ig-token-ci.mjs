// scripts/refresh-ig-token-ci.mjs
// Node 20+ ESM
import fs from "node:fs";
import path from "node:path";

const {
  FB_APP_ID,
  FB_APP_SECRET,
  IG_ACCESS_TOKEN: CURRENT_LONG_TOKEN,
  VERCEL_TOKEN,
  VERCEL_ORG_ID,
  VERCEL_PROJECT_ID,
  VERCEL_DEPLOY_HOOK_URL
} = process.env;

function required(name, value) {
  if (!value || String(value).trim() === "") {
    throw new Error(`Missing required env: ${name}`);
  }
  return value.trim();
}

const FB_APP_ID_V = required("FB_APP_ID", FB_APP_ID);
const FB_APP_SECRET_V = required("FB_APP_SECRET", FB_APP_SECRET);
const CURRENT_LONG_TOKEN_V = required("IG_ACCESS_TOKEN", CURRENT_LONG_TOKEN);
const VERCEL_TOKEN_V = required("VERCEL_TOKEN", VERCEL_TOKEN);
const VERCEL_ORG_ID_V = required("VERCEL_ORG_ID", VERCEL_ORG_ID);
const VERCEL_PROJECT_ID_V = required("VERCEL_PROJECT_ID", VERCEL_PROJECT_ID);

const FB_OAUTH_URL = "https://graph.facebook.com/v20.0/oauth/access_token";
const IG_ME_URL = "https://graph.instagram.com/me";
const VERCEL_ENV_LIST = `https://api.vercel.com/v10/projects/${encodeURIComponent(VERCEL_PROJECT_ID_V)}/env`;
const VERCEL_ENV_ADD = VERCEL_ENV_LIST;
const VERCEL_ENV_DEL = (envId) => `https://api.vercel.com/v10/projects/${encodeURIComponent(VERCEL_PROJECT_ID_V)}/env/${envId}`;

async function jsonOrThrow(res) {
  const txt = await res.text();
  let data;
  try { data = JSON.parse(txt); } catch { data = { raw: txt }; }
  if (!res.ok) {
    throw new Error(`HTTP ${res.status}: ${txt}`);
  }
  return data;
}

async function refreshToken() {
  // Exchange de long-lived token por novo long-lived token
  const url = new URL(FB_OAUTH_URL);
  url.searchParams.set("grant_type", "fb_exchange_token");
  url.searchParams.set("client_id", FB_APP_ID_V);
  url.searchParams.set("client_secret", FB_APP_SECRET_V);
  url.searchParams.set("fb_exchange_token", CURRENT_LONG_TOKEN_V);

  const res = await fetch(url, { method: "GET" });
  const data = await jsonOrThrow(res);
  const newToken = data.access_token;
  if (!newToken || typeof newToken !== "string") {
    throw new Error(`Exchange did not return access_token. Got: ${JSON.stringify(data)}`);
  }
  return newToken.trim();
}

async function validateToken(token) {
  const url = new URL(IG_ME_URL);
  url.searchParams.set("fields", "id,username");
  url.searchParams.set("access_token", token);
  const res = await fetch(url, { method: "GET" });
  const data = await jsonOrThrow(res);
  if (!data.id || !data.username) {
    throw new Error(`Validation failed: ${JSON.stringify(data)}`);
  }
  return data;
}

async function listVercelEnv() {
  const res = await fetch(VERCEL_ENV_LIST, {
    headers: {
      Authorization: `Bearer ${VERCEL_TOKEN_V}`
    }
  });
  return jsonOrThrow(res);
}

async function removeExistingIgEnv() {
  const envs = await listVercelEnv();
  const hits = (envs?.envs || []).filter(e => e.key === "IG_ACCESS_TOKEN");
  for (const e of hits) {
    const url = VERCEL_ENV_DEL(e.id);
    const res = await fetch(url, { method: "DELETE", headers: { Authorization: `Bearer ${VERCEL_TOKEN_V}` } });
    await jsonOrThrow(res);
    console.log(`Removed old IG_ACCESS_TOKEN (${e.target?.join(",") || "?"}) id=${e.id}`);
  }
}

async function addNewIgEnv(token) {
  const body = {
    type: "encrypted",
    key: "IG_ACCESS_TOKEN",
    value: token,
    target: ["production", "preview", "development"],
    // opcional: gitBranch: undefined
  };
  const res = await fetch(VERCEL_ENV_ADD, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${VERCEL_TOKEN_V}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });
  const data = await jsonOrThrow(res);
  console.log("Added IG_ACCESS_TOKEN to all targets:", data);
}

async function triggerDeployHook() {
  const hook = (process.env.VERCEL_DEPLOY_HOOK_URL || "").trim();
  if (!hook) {
    console.log("No VERCEL_DEPLOY_HOOK_URL provided — skipping immediate deploy trigger.");
    return;
  }
  const res = await fetch(hook, { method: "POST" });
  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`Deploy hook failed: HTTP ${res.status} ${txt}`);
  }
  console.log("Deploy hook triggered successfully.");
}

(async () => {
  try {
    console.log("Refreshing Instagram Long-Lived Token...");
    const newToken = await refreshToken();
    console.log(`New token length: ${newToken.length}`);

    console.log("Validating new token...");
    const me = await validateToken(newToken);
    console.log(`Valid for user: ${me.username} (id ${me.id})`);

    console.log("Updating Vercel Environment Variable IG_ACCESS_TOKEN...");
    await removeExistingIgEnv();
    await addNewIgEnv(newToken);

    await triggerDeployHook();

    // Mask token in logs
    const masked = newToken.slice(0, 6) + "..." + newToken.slice(-6);
    console.log("Done. New IG_ACCESS_TOKEN set:", masked);
  } catch (err) {
    console.error("FAILED:", err?.message || err);
    process.exit(1);
  }
})();