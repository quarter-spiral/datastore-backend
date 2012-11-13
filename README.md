# datastore-backend

A backend to store and retrieve data for [*entities*](#entity).

## Setup

### Prerequisites

Make sure you have the following installed:

* MongoDB

## API

Every entity can save a public and a private [*data sets*](#data-set). The public data sets a world readable while the private sets can only be read by [*authorized parties*](#authorized-party). New data sets can only be created by authorized parties. As well can changes to existing data sets only be made by authorized parties.

The data store must be accessed by HTTPS.

### Versioning

The current version of the API is ``v1``. **All URLs must be prefixed
with ``/v1``!**

### Create a new data set

#### Request

**POST** ``/:scope:/:UUID:``

##### Parameters

- **scope** [URL] [REQUIRED]: ``private`` or ``public``
- **UUID** [URL] [OPTIONAL]: The UUID of the entity the data set should be created for. If not provided a new UUID is generated.

##### Body
JSON encoded hash to be stored.

#### Response

##### Body

JSON encoded hash like this:
```{"uuid": "the-uuid-of-the-document", "data": "{\"some\":
\"data\"}"}```

### Change a data set

#### Request

**PUT** to ``/:scope:/:UUID:/:key:``

##### Parameters

- **scope** [URL] [REQUIRED]: ``private`` or ``public``
- **UUID** [URL] [REQUIRED]: The UUID of the entity the data set should be created for
- **key** [URL] [OPTIONAL]: Makes it possible to change only a subset of
  the stored data. The key determines which key in the hash is changed.
You can nest the key by separating it with a ``/`` (slash). If no key is
specified the whole data set will be replaced.

##### Body
JSON encoded hash to be stored.

#### Response

##### Body

JSON encoded hash like this:
```{"uuid": "the-uuid-of-the-document", "data": "{\"some\":
\"data\"}"}```

The response always contains the whole data set no matter if only a sub
set of the data set was changed (via a ``key`` parameter).

#### Example

##### Changing the whole data set

Send a ``PUT`` to ``/public/some-uuid`` with a JSON body like this
``{"some": "value"}``.

##### Changing a subset of a data set

If you have a data set with the uuid ``some-uuid`` that looks like this:

```javascript
{
  "colors": {
    "red": 100,
    "yellow": 12
  },
  "name": "A cool thing"
}
```

you could change it's name like this:

Send a ``PUT`` to ``/public/some-uuid/name`` with a JSON body like this
``{"name": "Another name"}``.

The data set would then look like this:

```javascript
{
  "colors": {
    "red": 100,
    "yellow": 12
  },
  "name": "Another name"
}
```

You could change the count of the color red like this:

Send a ``PUT`` to ``/public/some-uuid/colors/red`` with a JSON body like
this ``{"red": 99}``.

The data set would then look like this:

```javascript
{
  "colors": {
    "red": 99,
    "yellow": 12
  },
  "name": "A cool thing"
}
```

You could also change the count of all colors like this:

Send a ``PUT`` to ``/public/some-uuid/colors`` with a JSON body like
this ``{"colors": {"red": 92, "yellow": 10, "purple": 30}}``.

The data set would then look like this:

```javascript
{
  "colors": {
    "red": 92,
    "yellow": 10,
    "purple": 30
  },
  "name": "A cool thing"
}
```

It is also possible to add arbitrary nested hashed to the data set that
does not exist yet like this:

Send a ``PUT`` to ``/public/some-uuid/some/strange/thing`` with a JSON
body like this ``{"thing": {"yay": "YO"}}``.

The data set would then look like this:


```javascript
{
  "colors": {
    "red": 100,
    "yellow": 12
  },
  "name": "A cool thing",
  "some": {
    "strange": {
      "thing": {
        "yay": "YO"
      }
    }
  }
}
```

### Retrieve a data set

#### Request

**GET** to ``/:scope:/:UUID:``

##### Parameters

- **scope** [URL] [REQUIRED]: ``private`` or ``public``
- **UUID** [URL] [REQUIRED]: The UUID of the entity the data set should be created for

##### Body
Empty

#### Response

##### Body

JSON encoded hash like this:
```{"uuid": "the-uuid-of-the-document", "data": "{\"some\":
\"data\"}"}```

### Query for data sets

In order to retrieve all data sets meeting a given criteria at once you can use the query API. It allows you write MongoDB like queries to express your criteria. The actual query syntax is described in detail below.

To access the query API you need to authorize with an app level access token.

#### Request

**GET** to ``/tbd``

### Error case response

HTTP status codes used:

* **401** Request needs to be authenticated. Either there were no credentials present in the request or the given credentials are invalid.
* **403** The authenticated party is not authorized to carry out the action requested or a validation error occured
* **404** No data set found int he given scope for the given UUID

#### Body

Reason for the error encoded on JSON. Example:

```javascript
{
  error: 'Priviliges insufficient.'
}
```

## Glosary

### Entity

An entity is anything that is described by a 128bit UUID as described in [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt). Examples for entities are players but also games or developers.

### Authorized Party

An authorized party is either the owner of the entity, the entity itself or any party authorized to act on their behalf by those two. The specific semantics of this has yet to be defined.

### Data Set

A data set is a hash. Keys must be strings. Data sets support the following data types for their values:

* Null
* Boolean values (true/false)
* Integers
* Floating point numbers
* Strings
* Arrays (of any allowed data types)
* Data sets

Dates and times should be represented by numeric timestamps.
