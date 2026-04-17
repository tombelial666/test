def pytest_configure(config):
    config.addinivalue_line(
        "markers",
        "integration: calls real HTTP endpoints (requires FO_BASE_URL / network)",
    )
    config.addinivalue_line(
        "markers",
        "rate_limit: burst login POSTs — only on approved non-prod stands",
    )
    config.addinivalue_line(
        "markers",
        "playwright: UI test via Playwright (optional dependency)",
    )
