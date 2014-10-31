note
	description: "A implementation of WSF_RESPONSE_MESSAGE to send messages of type JSON"
	author: ""
	date: "2014-10-11"
	revision: "1.0"

class
	WSF_JSON_RESPONSE_MESSAGE

inherit
	WSF_RESPONSE_MESSAGE

create
	make

feature -- Initialization

	make
	do
		status_code := 200
	end

feature -- Status

	status_code: INTEGER

feature -- Header

	header: WSF_HEADER

feature -- Json access

	body: detachable STRING

feature -- Element change

	set_status_code (c: like status_code)
		do
			status_code := c
		end

	set_body (b: like body)
		do
			body := b
		end

	set_header (h: like header)
		do
			header := h
		end

feature {WSF_RESPONSE} -- Output

	send_to (res: WSF_RESPONSE)
		local
			--h: like header
			s: STRING_8
		do
			create s.make (64)
			create header.make
			s.append ("")
			append_html_body_code (s)
			res.set_status_code (status_code) --OK
			header.add_content_type ("application/json")
			header.add_header_key_value ("Access-Control-Allow-Origin", "*")
			res.put_header_text (header.string)
			res.put_string (s)
		end

feature {NONE} -- JSON Generation

	append_html_body_code (s: STRING_8)
		local
			b: like body
		do
			b := body
			--s.append ("<body>%N")
			if b /= Void then
				s.append (b)
			end
			--s.append ("%N</body>")
		end

end
