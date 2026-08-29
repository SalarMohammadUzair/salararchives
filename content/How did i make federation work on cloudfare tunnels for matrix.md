---
publish: true
title: change the nameHow did i make federation work on cloudfare tunnels for matrix
created: 2026-03-12T01:10:30.665Z
modified: 2026-02-19T16:13:25.438Z
---

On cloudfare dashboard go to

> security > WAF
> for  your domain

Add custom rule
`(http.host eq "matrix.salarmuzair.tech" and http.request.uri.path contains "/_matrix/") or (http.host eq "matrix.salarmuzair.tech" and http.request.uri.path contains "/.well-known/matrix/")`

Take actions:

- All remaining custom rules
- All managed rules
- All Super Bot Fight Mode Rules
- Browser Integrity Check
- Security Level
  Deploy and test
