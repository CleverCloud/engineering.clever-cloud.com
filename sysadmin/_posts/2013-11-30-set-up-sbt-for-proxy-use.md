---
locale: en
layout: post

title: "Set up your SBT for personal proxy use"
author: "durillon"
level: 1
---

This post will cover the new Clever Cloud Artifactory instance we deploy
two weeks ago, and how to set up SBT to make every client project use the proxy
server, without the need of specific configuration for the client.

### Requirements

To follow this post, we assume that you already know and use
[SBT](http://scala-sbt.org/). Nothing else is needed.

### What is / Why use Artifactory?

[Artifactory Open Source](http://www.jfrog.com/home/v_artifactory_opensource_overview)
 is an open
source proxy and cache server for build automation and dependencies
manager tools in the JVM world. It is what I call a "lazy mirror". It
acts like a Maven (or Ivy) server, and caches the artifacts "for ever".
It is not a proxy as described in RFC 2616. Eventually it becomes a
mirror of the repositories it serves.

As the Clever Cloud scalers are stateless, they don't keep the
dependencies of a project between two deployments. Therefore, every
dependency has to be downloaded for each deployment. Maven having the
(almost justified) reputation to download half the internet on a first
run, a deployment can take ages because of the deployments.

The first step we did was to initialize a local Maven (or Ivy, or SBT) cache
with common plugins and dependencies. But maintaining an up-to-date image
represents a lot of work. So, to speed up the download of dependencies,
we needed a Maven (resp. Ivy) repository next to the scalers; that means
in the same data center.

After considering various possibilities, the Artifactory solution was the best one:

* (Ridiculously) easy to set-up;
* The open-source (and free) version matches our needs without extra
  complexity;
* Supports high concurrency;
* No need to watch for desynchronisation;
* Can proxy any given repository (Maven, Ivy);
* Does not act like a HTTP proxy but like a maven repository (that's the
  important point);

So, eventually, [we started the server](http://maven.mirror.clvrcld.net:8080/artifactory/webapp/home.html?0)

### The bad part: client configuration.

Setting up the server was as easy as dropping a war in an application
server. Actually, it just consists of dropping a war in an application
server, and following the (crystal clear, well written) documentation.

Setting up the client wasn't that easy.

#### Maven client configuration

Maven was not a huge problem to set up. Some clicks in the artifactory
public (anonymous) interface give you the following (you can happily
remove the `servers` section):

{% highlight xml%}
<?xml version="1.0" encoding="UTF-8"?>
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0
http://maven.apache.org/xsd/settings-1.1.0.xsd"
xmlns="http://maven.apache.org/SETTINGS/1.1.0"
	 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <profiles>
	 <profile>
		<repositories>
		  <repository>
			 <snapshots>
				<enabled>false</enabled>
			 </snapshots>
			 <id>central</id>
			 <name>libs-release</name>
			 <url>http://maven.mirror.clvrcld.net:8080/artifactory/libs-release</url>
		  </repository>
		  <repository>
			 <snapshots />
			 <id>snapshots</id>
			 <name>libs-snapshot</name>
			 <url>http://maven.mirror.clvrcld.net:8080/artifactory/libs-snapshot</url>
		  </repository>
		</repositories>
		<pluginRepositories>
		  <pluginRepository>
			 <snapshots>
				<enabled>false</enabled>
			 </snapshots>
			 <id>central</id>
			 <name>plugins-release</name>
			 <url>http://maven.mirror.clvrcld.net:8080/artifactory/plugins-release</url>
		  </pluginRepository>
		  <pluginRepository>
			 <snapshots />
			 <id>snapshots</id>
			 <name>plugins-snapshot</name>
			 <url>http://maven.mirror.clvrcld.net:8080/artifactory/plugins-snapshot</url>
		  </pluginRepository>
		</pluginRepositories>
		<id>artifactory</id>
	 </profile>
  </profiles>
  <activeProfiles>
	 <activeProfile>artifactory</activeProfile>
  </activeProfiles>
</settings>
{% endhighlight %}

And that's it. We just add repositories that will be tried before the
user defined repositories. If an artifact is on a private repository, it
**will not** be downloaded through nor cached by our artifactory
instance.

#### SBT client configuration

##### Add ivy typesafe and SBT repositories to Artifactory

For the SBT instance, there is two things to do: add the ivy typesafe
repositories in the Artifactory and configure SBT to use our
Artifactory instance.

First, in Artifactory, we add the following remote repositories:

* sbt-plugin-releases => http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/
* typesafe-ivy-releases => http://repo.typesafe.com/typesafe/ivy-releases/
* typesafe-maven-releases => http://repo.typesafe.com/typesafe/maven-releases/

Then we put the first two in a new virtual repository (for example
*ivy-remote-repo*), then we add the third one to the *remote-repos* virtual repository.

##### Configure SBT

Here we come to the core of this post: setting up SBT to use our proxy
server while keeping the users out of the trouble of setting a specific
Clever Cloud configuring for their applications.

Rummaging through the documentation, we come across a
["Proxy" section](http://www.scala-sbt.org/release/docs/Detailed-Topics/Proxy-Repositories.html).

Let's follow it and define a ~/.sbt/repositories file:

{% highlight yaml %}
[repositories]
  local
  maven-local
  clever-ivy-proxy-releases: http://maven.mirror.clvrcld.net:8080/artifactory/ivy-remote-repos, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
  clever-maven-proxy-releases: http://maven.mirror.clvrcld.net:8080/artifactory/libs-release
  clever-maven-proxy-snapshots: http://maven.mirror.clvrcld.net:8080/artifactory/libs-snapshot
{% endhighlight %}{: .nowrap }

But [it's a trap](http://instanttrap.com/)! If we had used the
`-Dsbt.override.build.repos` option we would have overriden all the
project-defined repositories, even the private ones, which would have
led to build failures because of unretrievable dependencies.

So, at this point, no easy configuration was possible. It was either
**not** use the `~/.sbt/repositories` file, either override user-defined
repositories.

So let's be clever, and read about
[global settings](http://www.scala-sbt.org/release/docs/Detailed-Topics/Global-Settings.html).
We can put a `global.sbt` file in ~/.sbt/ (and ~/.sbt/0.13/ because of the new 0.13+ global files versioning) that will
be used each time we start SBT.

We keep our `repositories` file, and in the `global.sbt` file we put the following:

{% highlight scala %}
externalResolvers <<= (bootResolvers, externalResolvers) map (
	(boot: Option[Seq[sbt.Resolver]], ext: Seq[sbt.Resolver]) =>
		(boot.getOrElse(Seq.empty[sbt.Resolver]) ++ ext).distinct
)
{% endhighlight %}

Here, the `bootResolvers` value represents the content of the `repositories` file, and the `externalResolvers` value reflects the default SBT repositories plus project-defined repositories.

For curiosity sake, I added some *println*s in global.sbt:

{% highlight scala %}
externalResolvers <<= (bootResolvers, externalResolvers) map (
	(boot: Option[Seq[sbt.Resolver]], ext: Seq[sbt.Resolver]) => {
		boot.getOrElse(Seq.empty[sbt.Resolver]).foreach(b => println("Boot::: " + b.toString))
		ext.foreach(e => println("External::: " + e.toString))
		(boot.getOrElse(Seq.empty[sbt.Resolver]) ++ ext).distinct
	}
)
{% endhighlight %}

Then I ran `sbt compile` in a play project with additional *resolvers*:

{% highlight text %}
...
[info] Set current project to theproject (in build file:/theproject)
Boot::: FileRepository(local,FileConfiguration(true,None),Patterns(ivyPatterns=List(${ivy.home}/local/[organisation]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]), artifactPatterns=List(${ivy.home}/local/[organisation]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]), isMavenCompatible=false))
Boot::: Maven2 Local: file:/home/judu/.m2/repository/
Boot::: URLRepository(clever-ivy-proxy-releases,Patterns(ivyPatterns=List(http://maven.mirror.clvrcld.net:8080/artifactory/ivy-remote-repos/[organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]), artifactPatterns=List(http://maven.mirror.clvrcld.net:8080/artifactory/ivy-remote-repos/[organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]), isMavenCompatible=false))
Boot::: clever-maven-proxy-releases: http://maven.mirror.clvrcld.net:8080/artifactory/libs-release
Boot::: clever-maven-proxy-snapshots: http://maven.mirror.clvrcld.net:8080/artifactory/libs-snapshot
External::: FileRepository(local,FileConfiguration(true,None),Patterns(ivyPatterns=List(${ivy.home}/local/[organisation]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]), artifactPatterns=List(${ivy.home}/local/[organisation]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]), isMavenCompatible=false))
External::: Typesafe Releases Repository: http://repo.typesafe.com/typesafe/releases/
External::: Typesafe Snapshots Repository: http://repo.typesafe.com/typesafe/snapshots/
External::: Couchbase Maven Repository: http://files.couchbase.com/maven2
External::: Local Maven: file:/home/judu/.m2/repository
External::: public: http://repo1.maven.org/maven2/
...
{% endhighlight %}{: .nowrap }

We can see that bootResolvers contains the resolvers defined in the `~/.sbt/repositories` file, and externalResolvers contains the default + project defined repositories. As long as SBT will use the repositories in the given order, our proxy repository will be used before the external ones. (Because of the `boot ++ ext` order.)


### Sources

* [http://blog.dlecan.com/configurer-scala-sbt-repository-artifactory/](http://blog.dlecan.com/configurer-scala-sbt-repository-artifactory/) (in french) for the artifactory ivy configuration,
