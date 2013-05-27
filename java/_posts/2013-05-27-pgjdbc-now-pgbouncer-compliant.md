---
locale:  en
layout: post

title: "The PostgreSQL JDBC Driver is now PgBouncer compliant"
author: "kdecherf"
level: 1
---

Three years ago a discussion was launched on the Pgbouncer mailing-list \[1\] about the JDBC Driver which does not disable prepared statements when using `?prepareThreshold=0` in the connection string.

At Clever Cloud, we provide PostgreSQL databases behind PgBouncer to handle pools of connections. And to optimize these pools, we use the *transaction pooling mode*. This mode will prevent clients from using prepared statements as the session is only used for one transaction.

To be able to use this mode internally we manually applied a patch to the driver. After 8 months of inactivity, the pull-request \[2\]\[3\] was finally merged into the master branch of the driver.

Now we hope that the next version will be released soon.

References:

\[1\] [http://lists.pgfoundry.org/pipermail/pgbouncer-general/2010-February/000507.html](http://lists.pgfoundry.org/pipermail/pgbouncer-general/2010-February/000507.html)  
\[2\] [https://github.com/pgjdbc/pgjdbc/pull/9](https://github.com/pgjdbc/pgjdbc/pull/9)  
\[3\] [https://github.com/pgjdbc/pgjdbc/pull/58](https://github.com/pgjdbc/pgjdbc/pull/58)
