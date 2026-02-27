const params = JSON.parse(process.argv[2]);

if (!params.signed_funding_tx) {
  console.error('Missing signed_funding_tx in signed submit params');
  process.exit(1);
}

process.stdout.write(
  `${JSON.stringify({
    transaction: params.signed_funding_tx,
    multisig_configs: {},
    signatures: {},
  })}\n`,
);
