# Fleece — Copilot Instructions

This project includes the Fleece credit card research CLI (`pip install fleece-cli`). Use it for any credit card, rewards, or travel redemption question.

## When to use Fleece CLI

| User question | Command |
|---|---|
| Card details, fees, benefits | `fleece card "<name>" --json` |
| Earning rates by category | `fleece rates "<name>" --category <cat> --json` |
| Transfer partners | `fleece partners "<name>" --json` |
| Statement credits | `fleece credits "<name>" --json` |
| Recent card changes | `fleece news "<name>" --json` |
| Compare two cards | `fleece compare "<A>" "<B>" --json` |
| Portfolio / wallet gaps | `fleece wallet --json` |
| First-year ROI | `fleece roi "<name>" --json` |
| Card recommendations | `fleece recommend "<profile>" --json` |
| Merchant category lookup | `fleece mcc <code> --wallet --json` |
| Award flights | `fleece flights <ORIGIN> <DEST> --date <YYYY-MM-DD> --json` |
| Award hotels | `fleece hotels "<location>" --checkin <date> --checkout <date> --json` |
| User spending profile | `fleece profile show --json` |

## Notes

- `BRAVE_API_KEY` env var required for research commands; `mcc`, `flights`, `hotels`, `profile` work without it
- All `--json` output: check `ok` field before using `result`
- `fleece wallet` auto-loads saved cards from `fleece.db`
- Full docs: https://getfleece.io
