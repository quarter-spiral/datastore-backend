# datastore-backend

A backend to store and retrieve data for [*entities*](#entity).

## Setup

### Prerequisites

Make sure you have the following installed:

* MongoDB

## API

Every entity can save a [*data sets*](#data-set). The data sets can only be read by [*authorized parties*](#authorized-party). New data sets can only be created by authorized parties. As well can changes to existing data sets only be made by authorized parties.

The data store must be accessed by HTTPS.

### Versioning

The current version of the API is ``v1``. **All URLs must be prefixed
with ``/v1``!**

### Create a new data set

#### Request

**POST** ``/:UUID:``

##### Parameters

- **UUID** [URL]: The UUID of the entity the data set should be created for

##### Body
JSON encoded hash to be stored.

#### Response

##### Body

JSON encoded hash like this:
```{"uuid": "the-uuid-of-the-document", "data": "{\"some\":
\"data\"}"}```

### Change a data set

#### Request

**PUT** ``/:UUID:/:key:``

##### Parameters

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

Send a ``PUT`` to ``/some-uuid`` with a JSON body like this
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

Send a ``PUT`` to ``/some-uuid/name`` with a JSON body like this
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

Send a ``PUT`` to ``/some-uuid/colors/red`` with a JSON body like
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

Send a ``PUT`` to ``/some-uuid/colors`` with a JSON body like
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

Send a ``PUT`` to ``/some-uuid/some/strange/thing`` with a JSON
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

**GET** ``/:UUID:``

##### Parameters

- **UUID** [URL] [REQUIRED]: The UUID of the entity the data set should be created for

##### Body
Empty

#### Response

##### Body

JSON encoded hash like this:
```{"uuid": "the-uuid-of-the-document", "data": "{\"some\":
\"data\"}"}```

### Error case response

HTTP status codes used:

* **401** Request needs to be authenticated. Either there were no credentials present in the request or the given credentials are invalid.
* **403** The authenticated party is not authorized to carry out the action requested or a validation error occured
* **404** No data set found for the given UUID

#### Body

Reason for the error encoded on JSON. Example:

```javascript
{
  error: 'Priviliges insufficient.'
}
```

### Retrieve a batch of data sets

Batch requests may only be issued by authorized clients of the type ``app``.

#### Request

**GET** ``/batch``

##### Body

A JSON encoded object.

##### Parameters

**uuids**: An array of UUIDs to retrieve.

#### Response

##### Body

JSON encoded hash of the requested data sets like this:

```javascript
{
  "some-uuid": {
    "uuid": "some-uuid",
    "data": {"some": "data"}
  },
  "some-other-uuid": {
    "uuid": "some-other-uuid",
    "data": {"some-more": "different data"}
  }
}
```

If a data set can not be found it will not be present in the response hash.

## Glosary

### Entity

An entity is anything that is described by a 128bit UUID as described in [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt). Examples for entities are players but also games or developers.

### Authorized Party

Each request has to be authenticated by an OAuth token complying with the Quarter Spiral authentication guidelines. An authorized party for any entity is either an authorized client with the type ``user`` and the same UUID as the entity or any authorized client with the type ``app``.

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
