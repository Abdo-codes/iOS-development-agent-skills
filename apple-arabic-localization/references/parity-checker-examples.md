# Localization Parity Checker Examples

Use `scripts/check-localization-parity.py <repo-path>` after adding or changing Arabic and English localization resources.

## Missing Arabic Key

English:

```text
"settings.title" = "Settings";
```

Arabic:

```text
// key is missing
```

Expected finding:

```text
[error] en.lproj/Localizable.strings :: settings.title
  Missing ar key
```

## Placeholder Mismatch

English:

```text
"welcome.user" = "Welcome, %@";
```

Arabic:

```text
"welcome.user" = "مرحباً";
```

Expected finding:

```text
[error] en.lproj/Localizable.strings :: welcome.user
  Placeholder mismatch: ['%@'] vs []
```

## Untranslated Arabic Value

English:

```text
"paywall.restore" = "Restore Purchases";
```

Arabic:

```text
"paywall.restore" = "Restore Purchases";
```

Expected finding:

```text
[warning] en.lproj/Localizable.strings :: paywall.restore
  ar value matches en
```

## Bidirectional Text Risk

Arabic strings that start with placeholders can inherit the placeholder direction.

Arabic:

```text
"activity.like" = "%@ أعجب بمنشورك";
```

Expected finding:

```text
[warning] en.lproj/Localizable.strings :: activity.like
  Arabic value starts with a placeholder; review bidi isolation marks
```
