# PkMb
Our forked version of the [Mountebank](http://www.mbtest.org/) gem.

## Usage

### Pre-Requisite

Install PkMb:

```
npm install -g mountebank --production
```

Start PkMb:

```
mb --allowInjection --loglevel debug
```

I recommend reading the [Mountebank documentation](http://www.mbtest.org/docs/api/overview) for a deeper understanding of their API.

### Initialization

1. Add these to you environment hash (eg. add to your `.env` file)
	
	```
MOUNTEBANK_SERVER=127.0.0.1
MOUNTEBANK_PORT=2525
```

2. Include the lib in your `spec_helper`.

	```ruby
include 'pkmb'
```

