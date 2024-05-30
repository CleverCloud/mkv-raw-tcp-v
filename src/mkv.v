import net
import os

fn send_command(mut conn net.TcpConn, command string) ?string {
	conn.write_string(command) or {}
	return read_response(mut conn)
}

fn read_response(mut conn net.TcpConn) ?string {
	mut response := conn.read_line()
	if response.starts_with('+') || response.starts_with('-') || response.starts_with(':') {
		return response[1..]
	} else if response.starts_with('$') {
		length := response[1..].int()
		if length < 1 {
			return 'nil'
		}
		mut raw_response := ''
		for raw_response.len < length {
			raw_response += conn.read_line()
		}
		return raw_response
	} else if response.starts_with('*') {
		length := response[1..].int()
		mut elements := []string{}
		for _ in 0 .. length {
			elements << read_response(mut conn)?
		}
		return elements.join('')
	}
	return 'Unexpected response format'
}

fn main() {
	mkv_host := 'materiakv.eu-fr-1.services.clever-cloud.com'
	mkv_port := 6378
	mkv_password := os.environ()['KV_TOKEN']

	if mkv_password.len == 0 {
		eprintln("Error: The 'KV_TOKEN' environment variable is not set, set it with your Materia KV token")
		return
	}

	commands := [
		{
			'name':    'AUTH'
			'command': '*2\r\n$4\r\nAUTH\r\n$${mkv_password.len}\r\n${mkv_password}\r\n'
		},
		{
			'name':    'PING'
			'command': '*1\r\n$4\r\nPING\r\n'
		},
		{
			'name':    'SET1'
			'command': '*3\r\n$3\r\nSET\r\n$6\r\nmy_key\r\n$9\r\nthe_value\r\n'
		},
        {
			'name':    'SET2'
			'command': '*3\r\n$3\r\nSET\r\n$7\r\nmy_key2\r\n$10\r\nthe_value2\r\n'
		},
        {
			'name':    'SET3'
			'command': '*3\r\n$3\r\nSET\r\n$7\r\nmy_key3\r\n$10\r\nthe_value3\r\n'
		},
		{
			'name':    'KEYS'
			'command': '*2\r\n$4\r\nKEYS\r\n$1\r\n*\r\n'
		},
		{
			'name':    'GET'
			'command': '*2\r\n$3\r\nGET\r\n$7\r\nmy_key2\r\n'
		},
		{
			'name':    'DEL'
			'command': '*2\r\n$3\r\nDEL\r\n$7\r\nmy_key3\r\n'
		},
		{
			'name':    'FLUSHDB'
			'command': '*1\r\n$7\r\nFLUSHDB\r\n'
		},
	]

	mut conn := net.dial_tcp('${mkv_host}:${mkv_port}') or {
		eprintln('Connexion error: ${err}')
		return
	}

	for c in commands {
		response := send_command(mut conn, c['command']) or {
			eprintln('Command error: ${err}')
			return
		}
		println('${c['name']}: ${response.trim_right('\n')}')
	}

	conn.close() or { eprintln('Connexion close error: ${err}') }
}
