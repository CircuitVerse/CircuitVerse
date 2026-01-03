import log from "loglevel";
import logPrefix from "loglevel-plugin-prefix";

logPrefix.reg(log);
logPrefix.apply(log, {
  format: (level) => `${`[${level}]`.padStart(7)} Lookbook:`,
});

let logLevel = process.env.NODE_ENV === "development" ? 2 : 3;
if (window.LOG_LEVEL !== undefined) {
  logLevel = window.LOG_LEVEL;
}
log.setLevel(logLevel);

export default function loggerPlugin(Alpine) {
  Alpine.directive(
    "log",
    (el, { modifiers, expression }, { evaluateLater, effect }) => {
      let logFn =
        typeof expression === "string"
          ? (callback) => callback(expression)
          : evaluateLater(expression);
      effect(() =>
        logFn((message) => {
          const level = modifiers[0] || "debug";
          log[level](message);
        })
      );
    }
  );

  Alpine.magic("log", () => {
    return log;
  });

  Alpine.$log = log;
}

export { log };
