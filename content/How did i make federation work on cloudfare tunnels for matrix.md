---
title: change the nameHow did i make federation work on cloudfare tunnels for matrix
draft: false
tags:
---
 
On cloudfare dashboard go to
> security > WAF
for  your domain

Add custom rule
`(http.host eq "matrix.salarmuzair.tech" and http.request.uri.path contains "/_matrix/") or (http.host eq "matrix.salarmuzair.tech" and http.request.uri.path contains "/.well-known/matrix/")`

Take actions:
- All remaining custom rules
- All managed rules
- All Super Bot Fight Mode Rules
- Browser Integrity Check
- Security Level
Deploy and test