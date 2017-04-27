# Postal Ruby Library

This library provides an interface for sending e-mails using the [Postal](https://github.com/atech/postal) service and monitoring their status throughout their delivery journey.

It is very easy to get up and running with this library. Just follow the instructions below and you'll be sending messages before you know it.

## Installation

Add the `postal-ruby` gem to your Gemfile and run `bundle install` to install it.

```ruby
gem 'postal-ruby', '~> 1.0'
```

## Configuration

You'll need to tell the gem where your Postal server is using the `POSTAL_HOST` environment variable.

In order to send messages, you'll need a Server API key. You can generate one of these through your Postal web interface. This is a random string which is unique to your server and allows you authenticate to the API.  Once you've got the key, you can put it in a `POSTAL_KEY` environment variable or you can configure it as shown below:

```ruby
Postal.configure do |c|
  c.host = "https://postal.yourdomain.com"
  c.server_key = "DgJyr0BxvxITaaa"
end
```

No other configuration is nessessary.

## Sending Messages

To send a message through the API, just follow the example below. You do not need to specify all the fields shown below.

```ruby
Postal.send_message do |m|
  # This is the address that the message will be sent from. The address you enter here
  # must be one of the domains configured for your mail server.
  m.from        "AwesomeApp <sales@awesome.com>"

  # This is the address of the person/people receiving the message. You can pass multiple strings
  # to this method or call `to` multiple times to add other people.
  m.to          "Adam Cooke <adam@atechmedia.com>"
  m.cc          "sales@awesome.com", "dave@awesome.com"
  m.bcc         "itsasecret@awesome.com"

  # This is the subject of the message
  m.subject     "Welcome to Awesome App!"

  # This is the tag. Tagging allows you to categories and produce reports based
  # on the different types of email you send.
  m.tag         "welcome"

  # This is the content for the message. You must provide at least one of these options. We strongly
  # recommend sending messages with both parts.
  m.plain_body  "Helo there!"
  m.html_body   "<p>Hello there!</p>"

  # This adds a custom header to your outbound message. You can add as many of
  # these as you wish.
  m.header      "X-Example-Header", "Some value goes here!"

  # This attaches a file to the message. You should provide the name of the file,
  # the content type and the attachment content.
  m.attach      "terms.pdf", "application/pdf", File.read("terms.pdf")
end
```

If there are any issues with the data you've provided, you'll an `Postal::SendError` exception will be raised. This will contain a code & a message which you can use determine the issue.

```ruby
begin
  # Your call to `send_message`
rescue Postal::SendError => e
  e.code              #=> UnauthenticatedFromAddress
  e.error_message     #=> The From address is not authorised to send mail from this server
end
```

The result of the your send call will return a `Postal::SendResult` object which you can use, if you wish, to get further information about the messages that you've just sent.

```ruby
# This will return the ID of the message that was generated for
result.message_id     #=> e8e54169-0852-4a1f-b3b1-3a73c1ae10c7@amrp.postal.io

# This will return the number of actual recipients were sent this message
result.recipients     #=> 4

# This will allow you to view the message that was sent to a given recipient. This
# will return an Postal::Message object. See below for information about the data
# contained within.
message = result['sales@awesome.com']
message.id            #=> 12581
message.token         #=> Cssuvidz44MH

# You can also access all the recipients as a hash
result.recipients.each do |address, message|
  address             #=> "adam@atechmedia.com"
  message             #=> Postal::Message object
end
```

### Sending raw messages

If you already have a raw RFC2822 formatted message, you can send this to our API rather than the individual fields. You'll receive the same result object and exceptions as shown above.

```ruby
Postal.send_raw_message do |m|
  # This is the address that the message will be logged as being sent from
  m.mail_from       "sales@awesome.com"
  # This is an array of addresses that will receive the message. If you wish to BCC
  # the message to someone, they should be included here but not in the actual raw message.
  m.rcpt_to         "sales@awesome.com", "dave@awesome.com", "itsasecret@awesome.com"
  # This is the raw message as a string
  m.data            raw_message
end
```

## Finding messages

To find information (status, details, etc...) about a message that you've sent you can look it up by its ID. The most basic to do this is to simply call `find_by_id`.

```ruby
Postal::Message.find_by_id(12581)
```

However, to save your bandwidth the API will only return information that is requested by the client. By default, it will just return the `id` of the message and the `token`. When accessing methods on `Postal::Message` instances, calls will be made to our API automatically to retrieve the information needed. You can preload this data as shown below:

```ruby
message = Postal::Message.includes(:status, :details, :plain_body).find_by_id(12581)
message.status        #=> Sent
message.plain_body    #=> "Hello World!"
# This will return but with an additional call to the API to get the html_body expansion
message.html_body     => "<p>Hello World!</p>"
```

You can include any of the following expansions when looking up a message. If you're going to need to use the data you can save HTTP requests by ensuring that you request them before looking it up.

* `status` - includes details about the status of an outgoing message
* `details` - includes the core details about the message such as recipient, subject etc..
* `inspection` - includes information about spam & virus checking
* `plain_body` - includes the plain body
* `html_body` - includes the HTML body
* `attachments` - includes the attachments (including the data within them)
* `headers` - includes all the headers for the email
* `raw_message` - includes the full RFC2822 message

## Reading message information

Once you've got an `Postal::Message` object - either from the result of sending a message or by looking it up - you can use this to read properties on the message. The example below shows all the methods which are available to you on the message object.

```ruby
#
# Core Attribtues (always available)
#
message.id                        # => The numeric ID of the message
message.token                     # => The random token for this message

#
# Status Attributes (returned with the 'status' expansion)
#
message.status                    # => The status of the message
message.last_delivery_attempt     # => The time of the last delivery attempt
message.held?                     # => Is this message held?
message.hold_expiry               # => The time the hold on this message will expire

#
# Message Details (returned with the 'details' expansion)
#
message.rcpt_to                   # => The recipient address
message.mail_from                 # => The address the message was sent from
message.subject                   # => The subject
message.message_id                # => The message ID
message.timestamp                 # => The time the message was received by us
message.direction                 # => Either incoming or outgoing
message.size                      # => The size of the raw message in bytes
message.bounce?                   # => Is this message a bounce?
message.bounce_for_id             # => The ID that this message is a bounce for
message.tag                       # => The message tag
message.received_with_ssl?        # => Was this message received by us with SSL

#
# Inspection Details (returned with the 'inspection' expansion)
#
message.inspected?                # => Has this message been inspected for spam/threats?
message.spam?                     # => Is this message considered spam?
message.spam_score                # => The spam score for the message
message.threat?                   # => Is this message considered a threat?
message.threat_details            # => The details of any threat

#
# Plain Body (returned with the 'plain_body' expansion)
#
message.plain_body                # => The plain body

#
# HTML Body (returned with the 'html_body' expansion)
#
message.html_body                 # => The HTML body

#
# Attachments (returned with the 'attachments' expansion)
#
message.attachments.each do |attachment|
  attachment.filename             # => The name of an attachment
  attachment.content_type         # => The content type of an attachment
  attachment.size                 # => The size of an attachment in bytes
  attachment.hash                 # => A SHA1 hash of the attachment content
  attachment.data                 # => The raw attachment data
end

#
# Headers (returned with the 'headers' expansion)
#
messages.headers['x-something']   # => An array of all items for the x-something header
messages.headers.each do |key, values|
  values.each do |value|
    key                           # => The key for the header (in lowercase)
    value                         # => A value for the header
  end
end

#
# Raw Message (returned with the 'raw_message' expansion)
#
message.raw_message               # => The full RFC2822 message
```
