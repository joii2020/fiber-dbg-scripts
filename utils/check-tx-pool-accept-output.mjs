const output = process.argv[2] ?? '';
const start = output.indexOf('{');

if (start < 0) {
  console.error('Failed to parse ckb-cli test_tx_pool_accept output');
  process.exit(1);
}

const parsed = JSON.parse(output.slice(start));
if (parsed.error) {
  console.error(`ckb-cli test_tx_pool_accept RPC error: ${JSON.stringify(parsed.error)}`);
  process.exit(1);
}

const result = parsed.result;
const list = Array.isArray(result) ? result : [result];
for (const item of list) {
  if (item && (item.reject_reason || item.rejectReason)) {
    console.error(`Transaction rejected by tx-pool check: ${item.reject_reason || item.rejectReason}`);
    process.exit(1);
  }
}
