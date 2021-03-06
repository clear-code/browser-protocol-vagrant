local chrome_devtools = require("chrome-devtools-client")
local ftp = require("socket.ftp")
local ltn12 = require("ltn12")
pgmoon = require("pgmoon-mashape")

function split_text(text, delimiter)
  if text.find(text, delimiter) == nil then
    return { text }
  end

  local splited_texts = {}
  local last_position

  for splited_text, position in text:gmatch("(.-)"..delimiter.."()") do
    table.insert(splited_texts, splited_text)
    last_position = position
  end
  table.insert(splited_texts, string.sub(text, last_position))

  return splited_texts
end

function parse_connection_spec(connection_spec)
  parsed_connection_spec = {}
  for number, connection_spec_value in pairs(split_text(connection_spec, " ")) do
    key, value = connection_spec_value:match("(.-)=(.-)$")
    parsed_connection_spec[key] = value
  end
  return parsed_connection_spec
end

function save_xml(connection_spec, xml)
  parsed_connection_spec = parse_connection_spec(connection_spec)
  local pg = pgmoon.new(parsed_connection_spec)
  assert(pg:connect())

  assert(pg:query("CREATE TABLE IF NOT EXISTS converted_xml("..
                  "id serial,"..
                  "xml xml"..
                  ");"))
  assert(pg:query("INSERT INTO converted_xml (xml)"..
                  "VALUES (XMLPARSE(DOCUMENT " .. pg:escape_literal(xml) .. "))"))
end

if #arg ~= 2 then
  print("Usage: "..arg[0].." CONNECTION_SPEC SOURCE_HTML")
  print(" e.g.: "..arg[0].." 'database=test_db user=postgres' source.html")
  os.exit(1)
end

local connect_ip = "192.168.92.22"
local connect_port = "9223"

f, e = ftp.put{
  host = connect_ip,
  user = "vagrant",
  password = "vagrant",
  source = ltn12.source.file(io.open(arg[2], "r")),
  command = "stor",
  argument = "in.html",
}
if f == nil then
  print(f,e)
  os.exit(1)
end

local client = chrome_devtools.connect(connect_ip, connect_port)

client:page_navigate("file:///home/vagrant/in.html")
client:close()

client = chrome_devtools.connect(connect_ip, connect_port)
xml = client:convert_html_to_xml()
save_xml(arg[1], xml)
client:close()
os.exit(0)
