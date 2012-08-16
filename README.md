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

**PUT** ``/:scope:/:UUID:``

##### Parameters

- **scope** [URL] [REQUIRED]: ``private`` or ``public``
- **UUID** [URL] [REQUIRED]: The UUID of the entity the data set should be created for

##### Body
JSON encoded hash to be stored.

#### Response

##### Body

JSON encoded hash like this:
```{"uuid": "the-uuid-of-the-document", "data": "{\"some\":
\"data\"}"}```

### Retrieve a data set

#### Request

**GET** ``/:scope:/:UUID:``

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
