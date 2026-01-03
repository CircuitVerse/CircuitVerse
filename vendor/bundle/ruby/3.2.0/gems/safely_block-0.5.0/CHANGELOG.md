## 0.5.0 (2025-05-26)

- Dropped support for Ruby < 3.2

## 0.4.1 (2024-09-04)

- Added support for Datadog

## 0.4.0 (2023-05-07)

- Added exception reporting from [Errbase](https://github.com/ankane/errbase)
- Dropped support for Ruby < 3

## 0.3.0 (2019-10-28)

- Made `safely` method private to behave like `Kernel` methods

## 0.2.2 (2019-08-06)

- Added `context` option

## 0.2.1 (2018-02-25)

- Tag exceptions reported with `report_exception`

## 0.2.0 (2017-02-21)

- Added `tag` option to `safely` method
- Switched to keyword arguments
- Fixed frozen string error
- Fixed tagging with custom error handler

## 0.1.1 (2016-05-14)

- Added `Safely.safely` to not pollute when included in gems
- Added `throttle` option

## 0.1.0 (2015-03-15)

- Added `tag` option and tag exception message by default
- Added `except` option
- Added `silence` option

## 0.0.4 (2015-03-11)

- Added fail-safe

## 0.0.3 (2014-08-13)

- Added `safely` method

## 0.0.2 (2014-08-12)

- Added `default` option
- Added `only` option

## 0.0.1 (2014-08-12)

- First release
