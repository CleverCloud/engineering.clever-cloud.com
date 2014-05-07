---
locale: en
layout: post

title: "Kickstart your scala API client by turning JSON into case classes."
author: adam
level: 2
---

##Why code generation ?

When interacting with 3rd party json-based APIs from scala, modelling the API's responses with case classes can come in handy. If the JSON exhibits some properties (homogenous lists, for instance), it's easy to create a case class with the same structure. With some deserialization magic it's easier to deal with the API's responses.

<!--more-->

So basically is borring to write the case class, and the tool is doing it for you. The target was not to be perfect, but just to allow you quickly generate some case class.

You can test it here : [http://json2caseclass.cleverapps.io/](http://json2caseclass.cleverapps.io/)

So here is the repo :

<div class="github-widget" data-repo="CleverCloud/json2caseclass"> </div>


##Features

json 2 case class can generate
* nested case classes from JSON objects
* lists from JSON arrays
* scala base types from JSON primitives
* Option[T] for optional values

##Example

Here is an example with some github issues API data


json from github :
{% highlight json%}
[
  {
    "url": "https://api.github.com/repos/octocat/Hello-World/issues/1347",
    "html_url": "https://github.com/octocat/Hello-World/issues/1347",
    "number": 1347,
    "state": "open",
    "title": "Found a bug",
    "body": "I'm having a problem with this.",
    "user": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat"
    },
    "labels": [
      {
        "url": "https://api.github.com/repos/octocat/Hello-World/labels/bug",
        "name": "bug",
        "color": "f29513"
      }
    ],
    "assignee": {
      "login": "octocat",
      "id": 1,
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "somehexcode",
      "url": "https://api.github.com/users/octocat"
    },
    "milestone": {
      "url": "https://api.github.com/repos/octocat/Hello-World/milestones/1",
      "number": 1,
      "state": "open",
      "title": "v1.0",
      "description": "",
      "creator": {
        "login": "octocat",
        "id": 1,
        "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        "gravatar_id": "somehexcode",
        "url": "https://api.github.com/users/octocat"
      },
      "open_issues": 4,
      "closed_issues": 8,
      "created_at": "2011-04-10T20:09:31Z",
      "due_on": null
    },
    "comments": 0,
    "pull_request": {
      "html_url": "https://github.com/octocat/Hello-World/issues/1347",
      "diff_url": "https://github.com/octocat/Hello-World/issues/1347.diff",
      "patch_url": "https://github.com/octocat/Hello-World/issues/1347.patch"
    },
    "closed_at": null,
    "created_at": "2011-04-22T13:33:48Z",
    "updated_at": "2011-04-22T13:33:48Z"
  }
]
{% endhighlight %}


generated Scala :
{% highlight scala%}
case class User(login:String, id:Double, avatar_url:String, gravatar_id:String, url:String)
case class Labels(url:String, name:String, color:String)
case class Milestone(url:String, number:Double, state:String, title:String, description:String, creator:User, open_issues:Double, closed_issues:Double, created_at:String, due_on:String)
case class Pull_request(html_url:String, diff_url:String, patch_url:String)
case class Issue(url:String, html_url:String, number:Double, state:String, title:String, body:String, user:User, labels:List[Labels], assignee:User, milestone:Milestone, comments:Double, pull_request:Option[Pull_request], closed_at:Option[String], created_at:String, updated_at:String)
{% endhighlight %}




I hope you'll enjoy it. Feel free to propose new features and/or to contribute !

