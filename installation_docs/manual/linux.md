## API Setup
CircuitVerse API uses `RSASSA` cryptographic signing that requires `private` and associated `public` key. To generate the keys RUN the following commands in `CircuitVerse/`
```
openssl genrsa -out config/private.pem 2048
openssl rsa -in config/private.pem -outform PEM -pubout -out config/public.pem
```