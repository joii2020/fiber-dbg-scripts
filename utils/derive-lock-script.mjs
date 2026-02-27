#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";

const privateKey = process.argv[2] ?? process.env.CKB_PRIV_KEY;

if (!privateKey || !/^0x[0-9a-fA-F]{64}$/.test(privateKey)) {
    console.error("Usage: node derive-lock-script.mjs <CKB_PRIV_KEY>");
    process.exit(1);
}

const SECP256K1_BLAKE160_CODE_HASH =
    "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8";
const tempDir = mkdtempSync(join(tmpdir(), "fiber-ckb-key-"));
const keyPath = join(tempDir, "privkey");

try {
    writeFileSync(keyPath, `${privateKey}\n`, { mode: 0o600 });
    chmodSync(keyPath, 0o600);

    const result = spawnSync(
        "ckb-cli",
        [
            "util",
            "key-info",
            "--privkey-path",
            keyPath,
            "--output-format",
            "json",
            "--local-only",
            "--no-color",
        ],
        { encoding: "utf8" },
    );

    if (result.status !== 0) {
        process.stderr.write(result.stderr || "ckb-cli util key-info failed\n");
        process.exit(result.status ?? 1);
    }

    const output = result.stdout ?? "";
    const jsonStart = output.indexOf("{");
    if (jsonStart < 0) {
        console.error("Failed to parse ckb-cli output");
        process.exit(1);
    }

    const info = JSON.parse(output.slice(jsonStart));
    if (!info.lock_arg) {
        console.error("ckb-cli output missing lock_arg");
        process.exit(1);
    }

    process.stdout.write(
        JSON.stringify({
            code_hash: SECP256K1_BLAKE160_CODE_HASH,
            hash_type: "type",
            args: info.lock_arg,
        }),
    );
} finally {
    rmSync(tempDir, { recursive: true, force: true });
}
