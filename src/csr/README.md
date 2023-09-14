### Test Recap

Config CSR:
```
╔═════════════╦═════════════╦═════════════╗
║   PMPCFG    ║   DMPCFG    ║     EXC     ║
╠═════════════╬═════════════╬═════════════╣
║    FAIL     ║    FAIL     ║ RAISE (PMP) ║
║    FAIL     ║    PASS     ║ RAISE (PMP) ║
║    PASS     ║    FAIL     ║ RAISE (DMP) ║
║    PASS     ║    PASS     ║    PASS     ║
╚═════════════╩═════════════╩═════════════╝
```
