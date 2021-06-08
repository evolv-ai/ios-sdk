# EvolvLogger

## How to use it

```
let logger = EvolvLogger(system: "EvolvAppExample", destinations: [.console(), .file(url: URL(...)])

// logging level. [verbose, debug, info, warning and error].
logger.info("Hello World!")

logger.error("something is not working", context: ["user_id": "1234"])
```

### Outputting log messages

The `console` sends the log messages to the console and it's `debug` only, so no logs are sent on `release` builds.

The `file` destination stores logs messages to the provided local file.

Both accept a `Formatter` parameter to customize the log message, there's a default implementation.
