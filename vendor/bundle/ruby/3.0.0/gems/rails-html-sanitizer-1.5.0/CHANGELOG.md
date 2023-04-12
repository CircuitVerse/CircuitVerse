## 1.5.0 / 2023-01-20

* `SafeListSanitizer`, `PermitScrubber`, and `TargetScrubber` now all support pruning of unsafe tags.

  By default, unsafe tags are still stripped, but this behavior can be changed to prune the element
  and its children from the document by passing `prune: true` to any of these classes' constructors.

  *seyerian*

## 1.4.4 / 2022-12-13

* Address inefficient regular expression complexity with certain configurations of Rails::Html::Sanitizer.

  Fixes CVE-2022-23517. See
  [GHSA-5x79-w82f-gw8w](https://github.com/rails/rails-html-sanitizer/security/advisories/GHSA-5x79-w82f-gw8w)
  for more information.

  *Mike Dalessio*

* Address improper sanitization of data URIs.

  Fixes CVE-2022-23518 and #135. See
  [GHSA-mcvf-2q2m-x72m](https://github.com/rails/rails-html-sanitizer/security/advisories/GHSA-mcvf-2q2m-x72m)
  for more information.

  *Mike Dalessio*

* Address possible XSS vulnerability with certain configurations of Rails::Html::Sanitizer.

  Fixes CVE-2022-23520. See
  [GHSA-rrfc-7g8p-99q8](https://github.com/rails/rails-html-sanitizer/security/advisories/GHSA-rrfc-7g8p-99q8)
  for more information.

  *Mike Dalessio*

* Address possible XSS vulnerability with certain configurations of Rails::Html::Sanitizer.

  Fixes CVE-2022-23519. See
  [GHSA-9h9g-93gc-623h](https://github.com/rails/rails-html-sanitizer/security/advisories/GHSA-9h9g-93gc-623h)
  for more information.

  *Mike Dalessio*


## 1.4.3 / 2022-06-09

* Address a possible XSS vulnerability with certain configurations of Rails::Html::Sanitizer.

  Prevent the combination of `select` and `style` as allowed tags in SafeListSanitizer.

  Fixes CVE-2022-32209

  *Mike Dalessio*

## 1.4.2 / 2021-08-23

* Slightly improve performance.

  Assuming elements are more common than comments, make one less method call per node.

  *Mike Dalessio*

## 1.4.1 / 2021-08-18

* Fix regression in v1.4.0 that did not pass comment nodes to the scrubber.

  Some scrubbers will want to override the default behavior and allow comments, but v1.4.0 only
  passed through elements to the scrubber's `keep_node?` method.

  This change once again allows the scrubber to make the decision on comment nodes, but still skips
  other non-elements like processing instructions (see #115).

  *Mike Dalessio*

## 1.4.0 / 2021-08-18

* Processing Instructions are no longer allowed by Rails::Html::PermitScrubber

  Previously, a PI with a name (or "target") matching an allowed tag name was not scrubbed. There
  are no known security issues associated with these PIs, but similar to comments it's preferred to
  omit these nodes when possible from sanitized output.

  Fixes #115.

  *Mike Dalessio*

## 1.3.0

* Address deprecations in Loofah 2.3.0.

  *Josh Goodall*

## 1.2.0

* Remove needless `white_list_sanitizer` deprecation.

  By deprecating this, we were forcing Rails 5.2 to be updated or spew
  deprecations that users could do nothing about.

  That's pointless and I'm sorry for adding that!

  Now there's no deprecation warning and Rails 5.2 works out of the box, while
  Rails 6 can use the updated naming.

  *Kasper Timm Hansen*

## 1.1.0

* Add `safe_list_sanitizer` and deprecate `white_list_sanitizer` to be removed
  in 1.2.0. https://github.com/rails/rails-html-sanitizer/pull/87

  *Juanito Fatas*

* Remove `href` from LinkScrubber's `tags` as it's not an element.
  https://github.com/rails/rails-html-sanitizer/pull/92

  *Juanito Fatas*

* Explain that we don't need to bump Loofah here if there's CVEs.
  https://github.com/rails/rails-html-sanitizer/commit/d4d823c617fdd0064956047f7fbf23fff305a69b

  *Kasper Timm Hansen*

## 1.0.1

* Added support for Rails 4.2.0.beta2 and above

## 1.0.0

* First release.
