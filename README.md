# Clever Cloud's Materia KV raw TCP V demo

This project shows how to connect to Materia serverless KV store from [Clever Cloud](https://www.clever-cloud.com) and send commands through a TCP interface. It authenticates you with a [biscuit-based](https://www.biscuitsec.org/) token, sends commands and prints responses:
- `AUTH`
- `PING`
- `SET my_key the_value`
- `SET my_key2 the_value2`
- `SET my_key3 the_value3`
- `KEYS *`
- `GET my_key2`
- `DEL my_key3`
- `FLUSHDB`

## How to use it

You need [V language](https://vlang.io) and to create [a Materia KV add-on](https://developers.clever-cloud.com/doc/addons/materia-kv/) on Clever Cloud and set the `KV_TOKEN`:

```bash
export KV_TOKEN=<YOUR_KV_TOKEN>
v run .
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.