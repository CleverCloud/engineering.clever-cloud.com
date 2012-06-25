---
lang:  en
layout: post

title: "Traits extended by one-line case classes"
author: "belouin"
level: 3

---

Let's start talking about Scala, that pretty language making you able to use both object-oriented and functional programming paradigms.  
If you've never heard about it, take a look at [Scala School](http://twitter.github.com/scala_school/). You have to be at ease with trait and case class concepts to understand this post.

We all agree: keeping an abstract layer in your code is something good, but it's often painful when you have to rewrite n-times some children having a similar implementation.  
I always try to keep that children readable and fast understandable by making them one-liners.
Adding a child becomes quite easy, even for a non-scala developer.

##Trivial trait

Let's define a trait that will be the minimal representation of a message.

{% highlight scala linenos %}
trait Message {
  def id: String
  def content: String
}

case class DefaultMessage(id: String, content: String) extends Message
case class FromToMessage(id: String, content: String, from: String, to: String) extends Message
{% endhighlight %}

No need for writing overriding methods. Actually, _id_ and _content_ parameters are defined as methods that implicitly override Message's methods. Nice, isn't it?

##Trait using serialization

OK, that was quite simple. But how will you do if you have to create custom serializer object for each message type?
In that example, we will be using the lift framework to (de)serialize JSON.

{% highlight scala linenos %}
trait MessageSerializer[M <: Message] {
  implicit val format = DefaultFormats

  def apply(m: M): String = {
    Serialization.write(m)
  }

  def unapply(s: String)(implicit mf: Manifest[M]): Option[M] = {
    for {
      jvalue <- JsonParser.parseOpt(s)
      m <- jvalue.extractOpt[M]
    } yield m
  }
}

object DefaultMessageSerializer extends MessageSerializer[DefaultMessage]
object FromToMessageSerializer extends MessageSerializer[FromToMessage]
{% endhighlight %}

If you don't know what are apply and unapply methods, just take a look at this sample code to understand their usage:

{% highlight scala linenos %}
/* implicit call to apply method */
val a = DefaultMessage("1234", "Hello world!")
println(DefaultMessageSerializer(a)) // print: {"id": "1234", "content": "Hello world!"}

/* implicit call to unapply method */
"""{"id": "5678", "content": "Love", "from": "me", "to": "you"}""" match {
  case FromToMessageSerializer(m) => println(m) // print FromToMessage("5678", "Love", "me", "you")
  case _ => println("error")
}
{% endhighlight %}
