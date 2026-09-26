# AUDNPR-Widget

**A native Swift widget that tracks the AUD\/NPR exchange rate with automatic refresh and fallback data sources.**

The app is built as a simple macOS widget for quickly checking the current AUD to NPR rate without opening a browser.

## What it does

- fetches the current AUD\/NPR exchange rate
- refreshes automatically
- uses async networking with `URLSession`
- falls back to a second rate provider if the primary source fails
- decodes JSON responses into a small, typed data model
- runs as a native Swift widget

## Fallback strategy

The rate fetcher tries one provider first and uses a second provider as a fallback. If both fail, the fetch returns an error instead of silently showing stale data.

## Tech

`Swift` · `WidgetKit` · `URLSession`

## Why

I built this as a small personal utility for a rate I check regularly, and wanted it available at a glance.
